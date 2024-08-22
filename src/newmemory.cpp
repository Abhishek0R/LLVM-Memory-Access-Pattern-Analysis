#include "llvm/Passes/PassPlugin.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/IR/PassManager.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/IR/Instructions.h"
#include <map>
#include <string>

using namespace llvm;

namespace {
  struct MemoryAccessInfo {
    uint64_t Size;
    unsigned Count;
  };

  class MemoryAccessPatternsPass : public PassInfoMixin<MemoryAccessPatternsPass> {
  public:
    PreservedAnalyses run(Module &M, ModuleAnalysisManager &AM);

  private:
    std::map<Function*, unsigned> LocalVarCounters;
    std::string getVariableName(Value *V, Function *F, Instruction *I);
    std::string getArrayOrStructElementName(GetElementPtrInst *GEP, Function *F, Instruction *I);
  };
}

PreservedAnalyses MemoryAccessPatternsPass::run(Module &M, ModuleAnalysisManager &AM) {
  const DataLayout &DL = M.getDataLayout();
  std::map<Value*, std::string> VariableNames;
  std::map<std::string, MemoryAccessInfo> AccessMap;


  for (Function &F : M) {
    for (BasicBlock &BB : F) {
      for (Instruction &I : BB) {
        if (LoadInst *LI = dyn_cast<LoadInst>(&I)) {
          Value *Ptr = LI->getPointerOperand();
          std::string VarName = getVariableName(Ptr, &F, &I);
          uint64_t Size = DL.getTypeStoreSize(LI->getType());
          VariableNames[Ptr] = VarName;
          AccessMap[VarName].Size = Size;
          AccessMap[VarName].Count = 0;
        } else if (StoreInst *SI = dyn_cast<StoreInst>(&I)) {
          Value *Ptr = SI->getPointerOperand();
          std::string VarName = getVariableName(Ptr, &F, &I);
          uint64_t Size = DL.getTypeStoreSize(SI->getValueOperand()->getType());
          VariableNames[Ptr] = VarName;
          AccessMap[VarName].Size = Size;
          AccessMap[VarName].Count = 0;
        }
      }
    }
  }


  for (Function &F : M) {
    for (const auto &Entry : AccessMap) {
      AccessMap[Entry.first].Count = 0;
    }

    for (BasicBlock &BB : F) {
      for (Instruction &I : BB) {
        if (LoadInst *LI = dyn_cast<LoadInst>(&I)) {
          Value *Ptr = LI->getPointerOperand();
          std::string VarName = VariableNames[Ptr];
          AccessMap[VarName].Count++;
        } else if (StoreInst *SI = dyn_cast<StoreInst>(&I)) {
          Value *Ptr = SI->getPointerOperand();
          std::string VarName = VariableNames[Ptr];
          AccessMap[VarName].Count++;
        }
      }
    }

 
    errs() << F.getParent()->getSourceFileName() << ":" << F.getName() << "()\n";
    for (const auto &Entry : AccessMap) {
      if (Entry.second.Count != 0) {
        errs() << Entry.first << ": " << (Entry.second.Count) * (Entry.second.Size) << " bytes ("
               << Entry.second.Count << " time" << (Entry.second.Count > 1 ? "s" : "") << ")\n";
      }
    }
    errs() << "\n";
  }

  return PreservedAnalyses::all();
}

std::string MemoryAccessPatternsPass::getVariableName(Value *V, Function *F, Instruction *I) {
  if (GlobalVariable *GV = dyn_cast<GlobalVariable>(V)) {
    return GV->getName().str();
  }

  if (AllocaInst *AI = dyn_cast<AllocaInst>(V)) {
    if (AI->hasName()) {
      return AI->getName().str();
    } else {
      unsigned &Counter = LocalVarCounters[F];
      return "UnnamedLocalVar[" + std::to_string(Counter++) + "]";
    }
  }

  if (GetElementPtrInst *GEP = dyn_cast<GetElementPtrInst>(V)) {
    return getArrayOrStructElementName(GEP, F, I);
  }

  if (Instruction *Inst = dyn_cast<Instruction>(V)) {
    if (Inst->hasName()) {
      return Inst->getName().str();
    } else {
      unsigned &Counter = LocalVarCounters[F];
      return "UnnamedVar[" + std::to_string(Counter++) + "]";
    }
  }
  return "UnnamedVar";
}

std::string MemoryAccessPatternsPass::getArrayOrStructElementName(GetElementPtrInst *GEP, Function *F, Instruction *I) {
  Value *PtrOperand = GEP->getPointerOperand();
  std::string BaseName = getVariableName(PtrOperand, F, I);

  for (unsigned i = 1; i < GEP->getNumOperands(); ++i) {
    Value *IndexValue = GEP->getOperand(i);
    Type *SourceElementType = GEP->getSourceElementType();

    if (SourceElementType->isArrayTy()) {
      if (ConstantInt *CI = dyn_cast<ConstantInt>(IndexValue)) {
        unsigned Index = CI->getZExtValue();
        BaseName += "[" + std::to_string(Index) + "]";
      } else {
        BaseName += "[?]";
      }
    } else if (SourceElementType->isStructTy()) {
      if (ConstantInt *CI = dyn_cast<ConstantInt>(IndexValue)) {
        unsigned FieldIndex = CI->getZExtValue();
        BaseName += ".field" + std::to_string(FieldIndex);
      }
    }
  }

  return BaseName;
}


extern "C" LLVM_ATTRIBUTE_WEAK ::llvm::PassPluginLibraryInfo llvmGetPassPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "MemoryAccessPatternsPass", LLVM_VERSION_STRING,
          [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, ModulePassManager &MPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                  if (Name == "analyze-memory-access-patterns") {
                    MPM.addPass(MemoryAccessPatternsPass());
                    return true;
                  }
                  return false;
                });
          }};
}


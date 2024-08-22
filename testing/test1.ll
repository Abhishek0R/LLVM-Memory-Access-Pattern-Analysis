; ModuleID = 'test1.c'
source_filename = "test1.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.Point = type { i32, i32 }

@global_var = dso_local global i32 10, align 4
@high = dso_local global double 1.800000e+01, align 8
@__const.main.array = private unnamed_addr constant [5 x i32] [i32 1, i32 2, i32 3, i32 4, i32 5], align 16
@__const.main.pt = private unnamed_addr constant %struct.Point { i32 3, i32 4 }, align 4
@.str = private unnamed_addr constant [16 x i8] c"Global var: %d\0A\00", align 1
@.str.1 = private unnamed_addr constant [15 x i8] c"Local var: %d\0A\00", align 1
@.str.2 = private unnamed_addr constant [14 x i8] c"Array[2]: %d\0A\00", align 1
@.str.3 = private unnamed_addr constant [17 x i8] c"Point: (%d, %d)\0A\00", align 1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @process_array(i32* noundef %0, i32 noundef %1) #0 {
  %3 = alloca i32*, align 8
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  store i32* %0, i32** %3, align 8
  store i32 %1, i32* %4, align 4
  store i32 0, i32* %5, align 4
  br label %6

6:                                                ; preds = %21, %2
  %7 = load i32, i32* %5, align 4
  %8 = load i32, i32* %4, align 4
  %9 = icmp slt i32 %7, %8
  br i1 %9, label %10, label %24

10:                                               ; preds = %6
  %11 = load i32*, i32** %3, align 8
  %12 = load i32, i32* %5, align 4
  %13 = sext i32 %12 to i64
  %14 = getelementptr inbounds i32, i32* %11, i64 %13
  %15 = load i32, i32* %14, align 4
  %16 = mul nsw i32 %15, 2
  %17 = load i32*, i32** %3, align 8
  %18 = load i32, i32* %5, align 4
  %19 = sext i32 %18 to i64
  %20 = getelementptr inbounds i32, i32* %17, i64 %19
  store i32 %16, i32* %20, align 4
  br label %21

21:                                               ; preds = %10
  %22 = load i32, i32* %5, align 4
  %23 = add nsw i32 %22, 1
  store i32 %23, i32* %5, align 4
  br label %6, !llvm.loop !6

24:                                               ; preds = %6
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @manipulate_struct(%struct.Point* noundef %0) #0 {
  %2 = alloca %struct.Point*, align 8
  store %struct.Point* %0, %struct.Point** %2, align 8
  %3 = load %struct.Point*, %struct.Point** %2, align 8
  %4 = getelementptr inbounds %struct.Point, %struct.Point* %3, i32 0, i32 0
  %5 = load i32, i32* %4, align 4
  %6 = add nsw i32 %5, 1
  %7 = load %struct.Point*, %struct.Point** %2, align 8
  %8 = getelementptr inbounds %struct.Point, %struct.Point* %7, i32 0, i32 0
  store i32 %6, i32* %8, align 4
  %9 = load %struct.Point*, %struct.Point** %2, align 8
  %10 = getelementptr inbounds %struct.Point, %struct.Point* %9, i32 0, i32 1
  %11 = load i32, i32* %10, align 4
  %12 = add nsw i32 %11, 2
  %13 = load %struct.Point*, %struct.Point** %2, align 8
  %14 = getelementptr inbounds %struct.Point, %struct.Point* %13, i32 0, i32 1
  store i32 %12, i32* %14, align 4
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca [5 x i32], align 16
  %4 = alloca %struct.Point, align 4
  store i32 0, i32* %1, align 4
  store i32 20, i32* %2, align 4
  %5 = bitcast [5 x i32]* %3 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %5, i8* align 16 bitcast ([5 x i32]* @__const.main.array to i8*), i64 20, i1 false)
  %6 = bitcast %struct.Point* %4 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 4 %6, i8* align 4 bitcast (%struct.Point* @__const.main.pt to i8*), i64 8, i1 false)
  %7 = load i32, i32* @global_var, align 4
  %8 = add nsw i32 %7, 5
  store i32 %8, i32* @global_var, align 4
  %9 = load i32, i32* %2, align 4
  %10 = mul nsw i32 %9, 2
  store i32 %10, i32* %2, align 4
  %11 = getelementptr inbounds [5 x i32], [5 x i32]* %3, i64 0, i64 0
  call void @process_array(i32* noundef %11, i32 noundef 5)
  call void @manipulate_struct(%struct.Point* noundef %4)
  %12 = load i32, i32* @global_var, align 4
  %13 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([16 x i8], [16 x i8]* @.str, i64 0, i64 0), i32 noundef %12)
  %14 = load i32, i32* %2, align 4
  %15 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([15 x i8], [15 x i8]* @.str.1, i64 0, i64 0), i32 noundef %14)
  %16 = getelementptr inbounds [5 x i32], [5 x i32]* %3, i64 0, i64 2
  %17 = load i32, i32* %16, align 8
  %18 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([14 x i8], [14 x i8]* @.str.2, i64 0, i64 0), i32 noundef %17)
  %19 = getelementptr inbounds %struct.Point, %struct.Point* %4, i32 0, i32 0
  %20 = load i32, i32* %19, align 4
  %21 = getelementptr inbounds %struct.Point, %struct.Point* %4, i32 0, i32 1
  %22 = load i32, i32* %21, align 4
  %23 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([17 x i8], [17 x i8]* @.str.3, i64 0, i64 0), i32 noundef %20, i32 noundef %22)
  ret i32 0
}

; Function Attrs: argmemonly nofree nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #1

declare i32 @printf(i8* noundef, ...) #2

attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { argmemonly nofree nounwind willreturn }
attributes #2 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"Ubuntu clang version 14.0.0-1ubuntu1.1"}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}

# image_transform_ball

A new Flutter package project.

## Getting Started

This project is a starting point for a Dart
[package](https://flutter.dev/developing-packages/),
a library module containing code that can be shared easily across
multiple Flutter or Dart projects.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

## 效果展示
![image](./example/screencap/Screenshot_2022-06-30-16-13-24-081_com.example.example.jpg#pic_center =50%x50%)  
![image](./example/screencap/Screenshot_2022-06-30-16-14-20-769_com.example.example.jpg#/scale/20)    
![image](./example/screencap/Screenrecorder-2022-06-30-16-15-20-954.mp4!/scale/50)    
![image](./example/screencap/Screenrecorder-2022-06-30-16-15-56-870.mp4!/scale/50)    

## 使用方法  

1. import 'package:image_transform_ball/image_transform_ball.dart';

2. 
```dart
 child: ImageTransformBallWidget(
          assetImage: 'images/xxx.jpg',
          size: Size(180.0, 180.0),
          jd: 3,
        ),
```

## 说明  
assetImage: 本地资源图片  
size: 绘制区域大小  
jd: 取点的精度 默认为每隔3个点取样一次  

## 原理介绍  
解析出图片的原始字节数组，每个像素占用4个字节（ARGB）,根据图片的宽高将图片纹理转换为平面uv坐标，根据字节数组中的数据判断当前位置是否有颜色（暂定不是纯白就算有颜色）并且根据取样度jd 判断是否要取样该点坐标，赛选通过后 经过经纬度的转换将坐标添加到要绘制的坐标数组中并更新视图。

绘制的逻辑：  
取出传递进来的经纬度 根据当前的size算出最大球体半径 然后根据经纬度坐标转换为三维坐标
x = cos(wd) * cos(jd)
y = cos(wd) * sin(jd)
z = sin(wd)
此时可以绘制小圆点初步绘制出图像的底部俯视图

旋转交换逻辑：
GestureDetector 监听手势将dy,dx转为绕x轴和y的旋转变量 计算出旋转角度
绕x轴旋转矩阵变换为  
```
[  
    1       0       0  
    0       cos(rx) -sin(rx)  
    0      sin(rx) cos(rx)  
]  

绕y轴旋转矩阵变换为  
[  
    cos(rx)  0       sin(rx)  
    0        1       0  
    -sin(rx) 0       cos(rx)  
]  
```
将坐标经过两次矩阵变换得到最后的x,y,z坐标，然后绘制到画布上面，这里可以根据z坐标的正负来区分正反面的颜色

ImageBroser  
====
 
项目功能介绍，需要 （SDWebimageView ）支持
--------
* 图片浏览模块（仿网易新闻效果实现）
  * 1.必须实现此控制器的datasource
  * 2.可以加在网络图片
    * 通过坐标准换实现图片出现时放大，消失时缩小动画
  * 3.利用 collectionView 实现cell 的复用。
  * 4.cell 的子视图为 scrollview，在scrollview放一个 imageview
  * 5.放大缩小 为本demo的核心。
	* 可以添加每张图片的描述
###注意点
提供一种自己实现图片浏览的思路,必须实现三种方法
```objc 
- (NSInteger)numImagesForBroser:(ImageBroserController *)broser; // 图片个数
- (NSURL *)imageUrlAtIndex:(NSInteger)index broser:(ImageBroserController *)broser;// 图片链接地址
- (CGRect) theImageViewFrameBaseOnWindowAtIndex:(NSInteger)index broser:(ImageBroserController *)broser;//图片的尺寸，相对于window
```
![](https://github.com/zhudamao/ImageBroser/blob/master/sample.gif)  

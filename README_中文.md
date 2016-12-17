# WWFPSIndicator #
一个基于CADisplayLink实现的，可显示于屏幕上的FPS指示器。

[关于此FPS的更多说明](http://www.jianshu.com/p/86705c95c224)


# Usage #
将下面的代码添加到AppDelegate.m
```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    //开始
    [[WWFPSIndicator sharedInstance] start];
    //设置更新频率
    [WWFPSIndicator sharedInstance].frequency = WWFPSIndicatorRefreshFrequencyNormal;
    //设置文本样式
    [WWFPSIndicator sharedInstance].textStyle = WWFPSIndicatorTextStyleNormal;


    return YES;
}
```

用下面的代码停止FPS指示器:
```
//停止
[[WWFPSIndicator sharedInstance] stop];
```

Demo：
![Demo](https://raw.githubusercontent.com/Tidusww/WWFPSIndicator/master/fps.gif)

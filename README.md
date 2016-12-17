# WWFPSIndicator #
A CADisplayLink-based FPS indicator which can showe on the screen.

[more details for this FPSIndicator](http://www.jianshu.com/p/86705c95c224)



# Usage #
Add this code to AppDelegate.m
```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    //start
    [[WWFPSIndicator sharedInstance] start];
    //set the fps refresh frequency
    [WWFPSIndicator sharedInstance].frequency = WWFPSIndicatorRefreshFrequencyNormal;
    //set the text style
    [WWFPSIndicator sharedInstance].textStyle = WWFPSIndicatorTextStyleNormal;


    return YES;
}
```

use this code to stop:
```
    //stop
    [[WWFPSIndicator sharedInstance] stop];
```


![Demo](https://raw.githubusercontent.com/Tidusww/WWFPSIndicator/master/fps.gif)

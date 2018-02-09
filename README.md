# SwinjectContainerAnalyzer
Small command line tool to statically analyze your [Swinject](https://github.com/Swinject/Swinject) container usage.

Basically it tries to ensure that the types you try to `resolve` are also `register`ed somewhere.

Example warning:

![Example warning](https://github.com/ssnielsen/SwinjectContainerAnalyzer/blob/master/images/warning-example.png?raw=true)

## Usage
```
SwinjectContainerAnalyzer /Path/To/Code --strict
```

The `--strict` flag will result in Xcode to fail the build. Leave it out if you only want the comments.

To me it makes the most sense to have it as a custom build phase in Xcode. 

## Installation
1. Download latest release
2. Put in desired location 
3. Add build phase in Xcode (make sure that SwinjectContainerAnalyzer is executable)
4. Build your code

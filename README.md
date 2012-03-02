## AGSimpleImageEditorView

AGSimpleImageEditorView is just another image editor for iOS. The only features that this editor has are image cropping and rotation.

![Screenshot](http://dl.dropbox.com/u/2387405/Screenshots/AGSimpleImageEditorView.png)

## Installation

Copy over the files from the AGSimpleImageEditorView folder to your project folder.

## Usage

Wherever you want to use AGSimpleImageEditorView, import the appropriate header file and initialize as follows:

``` objective-c
#import "AGSimpleImageEditorView"
```

### Basic

``` objective-c
simpleImageEditorView = [[AGSimpleImageEditorView alloc] initWithImage:[UIImage imageNamed:@"sample"]];
[self.view addSubview:simpleImageEditorView];
```

#### Rotation

##### Left
``` objective-c
[simpleImageEditorView rotateLeft];
```
##### Right
``` objective-c
[simpleImageEditorView rotateRight];
```

#### Cropping

``` objective-c
simpleImageEditorView.ratio = 4./3.;
```

#### Resulting image

``` objective-c
UIImage *result = simpleImageEditorView.output;
```

## Contact

- [GitHub](http://github.com/arturgrigor)
- [Twitter](http://twitter.com/arturgrigor)

Let me know if you're using or enjoying this product.
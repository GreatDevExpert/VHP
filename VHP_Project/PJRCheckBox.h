#import <UIKit/UIKit.h>
#import "FormViewController.h"

#define PJRCheckboxDefaultHeight 24.0

#define kBoxRadius 0.1875
#define kBoxStrokeWidth 0.05

/**
 The posible states of the checkbox.
 */
typedef enum {
    PJRCheckboxStateUnchecked = NO, //Default
    PJRCheckboxStateChecked = YES,
    PJRCheckboxStateMixed
} PJRCheckboxState;

typedef enum {
    PJRCheckboxCHECKBOX,
    PJRCheckboxOPTION
} PJRCheckboxType;
/**
 Where the box is located in comparison to the text.
 */
typedef enum {
    PJRCheckboxAlignmentLeft,
    PJRCheckboxAlignmentRight //Default
} PJRCheckboxAlignment;

@interface PJRCheckBox: UIControl

@end
#define PJRCheckboxHeightAutomatic CGFLOAT_MAX
@interface CheckView : UIView

@property (nonatomic, weak) PJRCheckBox *checkbox;
@property (nonatomic, assign) BOOL selected;

@end
/**
 A custom checkbox control for iOS.
 */
@interface PJRCheckBox()

/**@name Properties*/
/**
 The label that displays the text for the checkbox.
 */
@property PJRCheckboxType type;
@property UIViewController* parentVC;
@property (nonatomic, retain) UILabel *titleLabel;
/**
 The current state of the checkbox
 */
@property (nonatomic, assign) PJRCheckboxState checkState;
/**
 The alignment of the check box. Wether the box is to the right or left of the text.
 */
@property (nonatomic, assign) PJRCheckboxAlignment checkAlignment UI_APPEARANCE_SELECTOR;
/**
 A manual setting to set the height of the checkbox. If set to PJRCheckHeightAutomatic, the check will fill the height of the control.
 */
@property (nonatomic, assign) CGFloat checkHeight UI_APPEARANCE_SELECTOR;
/**
 The location of the checkbox inside of the main control.
 */
@property (nonatomic, readonly) CGRect checkboxFrame;

/**@name Values*/
/**
 The object to return from `- (id)value` method when the checkbox is checked.
 */
@property (nonatomic, retain) id checkedValue;
/**
 The object to return from `- (id)value` method when the checkbox is unchecked.
 */
@property (nonatomic, retain) id uncheckedValue;
/**
 The object to return from `- (id)value` method when the checkbox is mixed.
 */
@property (nonatomic, retain) id mixedValue;
/**
 Returns one of the three "value" properties depending on the checkbox state. This is a convenience method so that if one has a large group of checkboxes, it is not necessary to write: if (someCheckbox == thatCheckbox) { if (someCheckbox.checkState == ......
 
 @return The value coresponding to the checkbox state.
 */
- (id)value;

/**@name Initalization*/
/**
 Initalize the checkbox with the defaults.
 
 @return A new checkbox control.
 */
- (id)init;
/**
 Initalize the checkbox cell with a custom frame size. The checkbox height will be the height of the frame.
 
 @param frame The frame to create the checkbox with.
 
 @return A new checkbox control.
 */
- (id)initWithFrame:(CGRect)frame;
/**
 Initalizes the checkbox cell with the default height, and a width to fit the text given.
 
 @param title The title to display in the checkbox.
 
 @return A new checkbox control.
 */
- (id)initWithTitle:(NSString *)title;
/**
 Initalizes the checkbox with the default check height, and a custom frame size and title.
 
 @param frame    The frame to initalize the checkbox cell with.
 @param title    The title to display.
 
 @return A new checkbox control.
 */
- (id)initWithFrame:(CGRect)frame title:(NSString *)title;
/**
 Initalizes the checkbox with a custom frame size, title, and check height.
 
 @param frame    The frame to initalize the checkbox cell with.
 @param title    The title to display.
 @param checkHeight The height of the checkbox.
 
 @return A new checkbox control.
 */
- (id)initWithFrame:(CGRect)frame title:(NSString *)title checkHeight:(CGFloat)checkHeight;

/**@name Actions*/
/**
 Change the state of the check programatically.
 
 @param state The state to change the checkbox to.
 */
- (void)setCheckState:(PJRCheckboxState)state;//Change state programitically
/**
 Toggle the check state between unchecked and checked.
 */
- (void)toggleCheckState;
/**
 Sets the font size, so that the label text is the same height as the checkbox.
 */
- (void)autoFitFontToHeight;
/**
 Sets the with of the checkbox so that all the text can fit on one line.
 */
- (void)autoFitWidthToText;
/**
 Returns the shape to be displayed in the checkbox when the check state is "checked".
 
 @note To use a custom shape, create a subclass of PJRCheckbox, and override this method. See the method for more details.
 
 @return A UIBezierPath representing the shape to render when the checkbox is checked.
 */
- (UIBezierPath *)getDefaultShape;

/**@name Appearance*/
/**
 Wether or not to draw the check box flat, without a glossy overlay.
 */
@property (nonatomic, assign) BOOL flat UI_APPEARANCE_SELECTOR;
/**
 The width of the stroke around the box.
 */
@property (nonatomic, assign) CGFloat strokeWidth UI_APPEARANCE_SELECTOR;
/**
 The color of the stroke around the box.
 */
@property (nonatomic, retain) UIColor *strokeColor UI_APPEARANCE_SELECTOR;
/**
 The color of the check.
 */
@property (nonatomic, retain) UIColor *checkColor UI_APPEARANCE_SELECTOR;
/**
 The color to fill the box with when checked.
 */
@property (nonatomic, retain) UIColor *tintColor UI_APPEARANCE_SELECTOR;
/**
 The color of the box when unchecked.
 */
@property (nonatomic, retain) UIColor *uncheckedColor UI_APPEARANCE_SELECTOR;
/**
 The corner radius of the box.
 */
@property (nonatomic, assign) CGFloat radius UI_APPEARANCE_SELECTOR;

@end
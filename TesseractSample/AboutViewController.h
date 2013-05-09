//
//  AboutViewController.h
//  EZOCR
//
//  Created by LIANGJUN JIANG on 5/9/13.
//
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UITableViewController {
@private
    
    NSArray *credits;
    NSArray *authors;
    UIView *tableHeaderView;
    UIButton *photoButton;
    UITextField *nameTextField;
    UITextField *overviewTextField;
    UITextField *versionTextField;
}

@property (nonatomic, retain) NSArray *credits;
@property (nonatomic, retain) NSArray *authors;
@property (nonatomic, retain) NSArray *instructions;

@property (nonatomic, retain) IBOutlet UIView *tableHeaderView;
@property (nonatomic, retain) IBOutlet UIButton *photoButton;
@property (nonatomic, retain) IBOutlet UITextField *nameTextField;
@property (nonatomic, retain) IBOutlet UITextField *overviewTextField;
@property (nonatomic, retain) IBOutlet UITextField *versionTextField;
@end
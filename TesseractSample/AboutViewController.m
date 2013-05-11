//
//  AboutViewController.m
//  EZOCR
//
//  Created by LIANGJUN JIANG on 5/9/13.
//
//

#import "AboutViewController.h"


@implementation AboutViewController

@synthesize credits;
@synthesize authors, instructions;
@synthesize tableHeaderView;
@synthesize photoButton;
@synthesize nameTextField, overviewTextField, versionTextField;

-(id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self){
        
        
    }
    
    return self;
}

- (void)viewDidLoad {
    // Create and set the table header view.
    if (tableHeaderView == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"DetailHeaderView" owner:self options:nil];
        self.tableView.tableHeaderView = tableHeaderView;
    }
    
    
    self.title = NSLocalizedString(@"About", @"About");
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    self.tableView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    self.nameTextField.text = @"EZOCR";
    self.overviewTextField.text = @"An Image to Text Tool";
    self.versionTextField.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSDictionary *developer = @{@"name":@"Liangjun Jiang, 2010.longhorn@gmail.com", @"title":@"Developers"};
    NSDictionary *creative= @{@"name":@"Liangjun Jiang", @"title":@"Creative"};
    self.authors = @[developer, creative];
    NSDictionary *credit1 = @{@"name":@"TesseractSample", @"title":@"by Ângelo Suzuki ", @"url":@""};
    NSDictionary *credit2 = @{@"name":@"KNSemiModalViewController",@"title":@"by Kent Nguyen",@"url":@"https://github.com/kentnguyen/KNSemiModalViewController" };
    NSDictionary *credit3 = @{@"name":@"MBProgressHUD", @"title":@"by Matej Bukovinski", @"url":@"https://github.com/jdg/MBProgressHUD"};
    NSDictionary *credit4 = @{@"name":@"tesseract-ocr", @"title":@"by An OCR Engine that was developed at HP Labs between 1985 and 1995... and now at Google.",@"url":@"https://code.google.com/p/tesseract-ocr/"};
    
    
    
    self.credits = @[credit1, credit2, credit3, credit4];
    self.instructions = @[@"How to use it"];
    
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}


- (void)viewDidUnload {
    self.tableHeaderView = nil;
	self.photoButton = nil;
	self.nameTextField = nil;
	self.overviewTextField = nil;
	self.versionTextField = nil;
	[super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}



#pragma mark -
#pragma mark UITableView Delegate/Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    // Return a title or nil as appropriate for the section.
    switch (section) {
        case 0:
            title = @"Authors";
            break;
        case 1:
            title = @"Credits";
            break;
            //        case 2:
            //            title = @"Instruction";
            //            break;
            //
        default:
            break;
    }
    return title;;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    
    /*
     The number of rows depends on the section.
     In the case of ingredients, if editing, add a row in editing mode to present an "Add Ingredient" cell.
	 */
    switch (section) {
        case 0:
            return self.authors.count;
            break;
        case 1:
            return self.credits.count;
            break;
            //        case 2:
            //            return self.instructions.count;
		default:
            break;
    }
    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    // For the Ingredients section, if necessary create a new cell and configure it with an additional label for the amount.  Give the cell a different identifier from that used for cells in other sections so that it can be dequeued separately.
    //    if (indexPath.section == 0) {
    
    static NSString *authorCellIdentifier = @"IngredientsCell";
    
    cell = [tableView dequeueReusableCellWithIdentifier:authorCellIdentifier];
    
    if (cell == nil) {
        // Create a cell to display an ingredient.
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:authorCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSString *subName = [NSString stringWithFormat:@"%@, %@",self.credits[indexPath.row][@"name"],self.credits[indexPath.row][@"title"] ];
    
    NSString *name = (indexPath.section == 0)?self.authors[indexPath.row][@"name"]:subName;
    NSString *subtitle = (indexPath.section == 0)?self.authors[indexPath.row][@"title"]:self.credits[indexPath.row][@"url"];
    
    
    cell.textLabel.text = name;// self.authors[indexPath.row][@"name"];
    cell.detailTextLabel.text = subtitle; //self.authors[indexPath.row][@"title"];
    if (indexPath.section ==1) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
    }
    
    //    }
    //
    //    else {
    //         // If necessary create a new cell and configure it appropriately for the section.  Give the cell a different identifier from that used for cells in the Ingredients section so that it can be dequeued separately.
    //        static NSString *MyIdentifier = @"GenericCell";
    //
    //        cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    //        if (cell == nil) {
    //            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    //            cell.accessoryType = UITableViewCellAccessoryNone;
    //        }
    //
    //        cell.textLabel.text = self.credits[indexPath.row][@"name"];
    //        cell.detailTextLabel.text = self.credits[indexPath.row][@"title"];
    //    }
    return cell;
}


#pragma mark - Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    if (indexPath.section ==2) {
    //        
    //    } else {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    //    }
}


@end

//
//  SSViewController.m
//  SimonSays
//
//  Created by Michael Spearman on 7/29/14.
//  Copyright (c) 2014 Michael Spearman. All rights reserved.
//

#import "SSViewController.h"

@interface SSViewController ()
@property (nonatomic) int playing;
@property (nonatomic) int userInput;
@property (nonatomic) int state;
@property (nonatomic) int prev;
@property (weak, nonatomic) IBOutlet UIButton *zeroButton;
@property (weak, nonatomic) IBOutlet UIButton *oneButton;
@property (weak, nonatomic) IBOutlet UIButton *twoButton;
@property (weak, nonatomic) IBOutlet UIButton *threeButton;
@property (weak, nonatomic) IBOutlet UIButton *play;
@property (nonatomic, strong) NSMutableArray *sequence;
@property (strong, nonatomic) NSMutableArray *ans;
@property (weak, nonatomic) IBOutlet UITextField *statusText;

@end

@implementation SSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.statusText setHidden:YES];
    self.state = 0;
    self.ans = [[NSMutableArray alloc] init];
    self.sequence = [[NSMutableArray alloc] init];
    float sizeWidth = [self view].bounds.size.width/2;
    float sizeHeight = [self view].bounds.size.height/2;
    // Configure button sizes
    CGRect topLeft = CGRectMake(0, 0, sizeWidth, sizeHeight);
    _zeroButton.frame = topLeft;
    CGRect topRight = CGRectMake(sizeWidth, 0, sizeWidth, sizeHeight);
    _oneButton.frame = topRight;
    CGRect bottomLeft = CGRectMake(0, sizeHeight, sizeWidth, sizeHeight);
    _twoButton.frame = bottomLeft;
    CGRect bottomRight = CGRectMake(sizeWidth, sizeHeight, sizeWidth, sizeHeight);
    _threeButton.frame = bottomRight;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)changeColor:(id)sender {
    self.view.backgroundColor = [sender titleColorForState:UIControlStateNormal];
    [self.ans addObject:sender];
}

-(IBAction)play:(id)sender {
    [sender setHidden:YES];
    int color;
    do { color = rand() % 4; }
    while (color == self.prev);
    switch (color) {
        case 0:
            [self.sequence addObject:_zeroButton];
            NSLog(@"ADDED: GREEN");
            break;
        case 1:
            [self.sequence addObject:_oneButton];
            NSLog(@"ADDED: BLUE");
            break;
        case 2:
            [self.sequence addObject:_twoButton];
            NSLog(@"ADDED: RED");
            break;
        case 3:
            [self.sequence addObject:_threeButton];
            NSLog(@"ADDED: YELLOW");
            break;
        default:
            break;
    }
    self.prev = color;
    [self animate:0];
}

- (void) animate:(int) iteration
{
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionTransitionFlipFromRight
                     animations:^{ self.view.backgroundColor = [_sequence[iteration] titleColorForState:UIControlStateNormal]; }
                     completion:^(BOOL finished) {
                         if (iteration < [_sequence count] - 1) {
                             [self animate:iteration + 1];
                         } else {
                             self.view.backgroundColor = [_sequence[0] titleColorForState:UIControlStateNormal];
                             self.playing = 1;
                             [self handleUser];
                         }
                     }
     ];
}

- (void) handleUser
{
    switch (_state) {
        // Waiting for user input
        case 0:
            if (([_ans count] == [_sequence count]) && (_ans != 0))
                _state = 1;
            break;
        // Determining user input
        case 1:
            for (int i = 0; i < [_sequence count]; i++) {
                if (_sequence[i] == _ans[i]) {
                    _state = 2;
                } else {
                    _state = 3;
                    break;
                }
            }
            break;
        // Correct user input
        case 2:
            [self.statusText setText:@"CORRECT"];
            [self.statusText setHidden:NO];
            [NSThread sleepForTimeInterval:1];
            NSLog(@"YOU ARE CORRECT");
            _state = 0;
            _ans = [[NSMutableArray alloc] init];
            [self play:_play];
            break;
        case 3:
            [self.statusText setText:@"INCORRECT"];
            [self.statusText setHidden:NO];
            NSLog(@"YOU ARE INCORRECT");
            [NSThread sleepForTimeInterval:1];
            [self.play setHidden:NO];
            [self setPlaying:0];
            [self viewDidLoad];
            break;
    }
    if (self.playing)
        [self performSelector:@selector(handleUser) withObject:nil afterDelay:.1];
}
@end

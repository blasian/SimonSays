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
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UIButton *zeroButton;
@property (weak, nonatomic) IBOutlet UIButton *oneButton;
@property (weak, nonatomic) IBOutlet UIButton *twoButton;
@property (weak, nonatomic) IBOutlet UIButton *threeButton;
@property (weak, nonatomic) IBOutlet UIButton *play;
@property (nonatomic, strong) NSMutableArray *sequence;
@property (strong, nonatomic) NSMutableArray *ans;
@property (weak, nonatomic) IBOutlet UILabel *highscoreLabel;
@property (nonatomic) int highscore;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@end

@implementation SSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.scoreLabel.hidden = YES;
    self.highscoreLabel.hidden = YES;
    self.highscore = 0;
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
    [UIView animateWithDuration:.25
                     animations: ^{
                         self.view.backgroundColor = [sender titleColorForState:UIControlStateNormal];
                     }];
    [UIView animateWithDuration:.5
                     animations: ^{
                         self.view.backgroundColor = [UIColor blackColor];
                     }];
    [self.ans addObject:sender];
}

-(IBAction)play:(id)sender {
    [sender setHidden:YES];
    [self.status setHidden:YES];
    int color;
    do { color = arc4random() % 4; }
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
    self.scoreLabel.hidden = NO;
    self.highscoreLabel.hidden = NO;
    self.playing = 1;
    [self animate:0];
}

- (void) animate:(int) iteration
{
    [UIView animateWithDuration:.5 delay:.25 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.view.backgroundColor = [_sequence[iteration] titleColorForState:UIControlStateNormal];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:.25
                                          animations:^{
                                              self.view.backgroundColor = [UIColor blackColor];
                                          }
                                          completion:^(BOOL completion) {
                                              if (iteration < [_sequence count] - 1) {
                                                  [self animate:iteration + 1];
                                              } else {
                                                  [self handleUser];
                                              }
                                          }];
                     }
     ];
}

- (void) handleUser
{
    switch (_state) {
        // Waiting for user input
        case 0:
            if (([_ans count] == [_sequence count]) && ([_ans count] != 0))
                _state = 1;
            break;
        // Determining user input
        case 1:
            for (int i = 0; i < [_ans count]; i++) {
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
            NSLog(@"YOU ARE CORRECT");
            [NSThread sleepForTimeInterval:1];
            _state = 0;
            if ([_ans count] > _highscore) {
                _highscore++;
                _highscoreLabel.text = [[NSString alloc] initWithFormat: @"Highscore: %d", _highscore];
            }
            _ans = [[NSMutableArray alloc] init];
            [self play:_play];
            break;
        // Incorrect user input
        case 3:
            [self.status setHidden:NO];
            NSLog(@"YOU ARE INCORRECT");
            [self.play setHidden:NO];
            [self setPlaying:0];
            [self viewDidLoad];
            break;
    }
    if (self.playing)
        self.scoreLabel.text = [[NSString alloc] initWithFormat:@"%d / %d", (int)[_ans count], (int)[_sequence count]];
        [self performSelector:@selector(handleUser) withObject:nil afterDelay:.1];
}
@end

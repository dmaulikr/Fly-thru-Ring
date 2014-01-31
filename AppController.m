//
//  AppController.m
//  Ball Shooter
//
//

#import "AppController.h"
#import <OpenGL/CGLMacro.h>

/// This is the players targeting system
extern void shipNavigate(void);


static double gameDuration =0;
/// This is the "time index" used for integrating the position
static int idx = 0;

/// These are the variables that define the game
/// This is the starting position of the ring that the player will to fly into.
static double _ring_x=0.0;
static double _ring_y=0.0;
/// This is the velocity of the ship that the player will to shoot.
//static double _ship_speed=1.5;
/// This is the orientation of the ship, in degrees
static double _ship_angle;
/// This is the ship's position
static double _ship_x=0.0;
/// This is the ship's position
static double _ship_y=0.0;
/// This is the ship's thrust
static double _ship_thrust = 1.0;
/// This is the ship's mass
static double _ship_mass = 50.0;


/// This is the starting position of the ring that the player will to fly into.
double ring_x;
double ring_y;
/// This is the ships orientation
double ship_angle;
/// This is the ship's x position
double ship_x=0.0;
/// This is the ship's y position
double ship_y=0.0;
/// This is the ship's mass
double ship_mass = 50.0;
/// This is the ship's thrust
double ship_thrust = 1.0;

/// This is the ship's x velocity
double ship_v_x;
/// This is the ship's y velocity
double ship_v_y;


/// The procedure is to set this if the ship's thrusters are set on
int ship_thrustOn = 0;
/// The navigation procedure may set the variable ship_dAngle to amount it wants to change
///  the ships orientation by: -15..15 degrees.
double ship_dAngle;

/// This is the acceleration of the ship
static double acceleration_x[3];
static double acceleration_y[3];
/// This is the velocity of the ship
static double velocity_x[3];
static double velocity_y[3];
/// This is the position of the ship
static double position_x[3];
static double position_y[3];

/** Does Simpson's rule for integration
    @param f The function to integrate
    @param tScale the scale between time index 0 and time index 1
    @return The integrated valued
 */
static double SimpsonsRule(double* f, double tScale)
{
    return (f[0]+f[2]+4*f[1])*tScale*2.0/6.0;
}


/** Doubly integrates acceleration into position
    @param idx The current time index
    @param position The current position function
    @param velocity The current velocity function
    @param acceleration The current acceleration function
    @param tScale the scale between time index 0 and time index 1
    @return The newly integrated value.
 */
static double doubleIntegrate(int idx, double* position, double* velocity, double* acceleration, double tScale)
{
    // Perform integration of acceleration to get the velocity
    double newV = SimpsonsRule(acceleration, tScale);
    double tmp, velocity3;
    // Roll thru the acceleration
    acceleration[0] = acceleration[1];
    acceleration[1] = acceleration[2];
    switch ((idx & 1))
    {
        default:
        case 0:
            tmp = velocity[2];
            // velocity from t0 to t2
            velocity[2] = velocity[0] + newV;
            // Roll thru velocity
            velocity[0] = velocity[1];
            velocity[1] = tmp;
            // position from t0 to t2
            position[0] += SimpsonsRule(velocity, tScale);
            return position[0];
        case 1:
            // velocity from t1 to t3
            velocity3 = velocity[1] + newV;
            // Roll thru velocity
            velocity[0] = velocity[1];
            velocity[1] = velocity[2];
            velocity[2] = velocity3;
            // position from t1 to t3
            position[1] += SimpsonsRule(velocity, tScale);
            return position[1];
    }
}


/** This is used to copy the game play variables to something that the player can see.
    This is copied to prevent the player from cheating and changing the position of the ring or shooter.
 */
static void copyPlayerStateVariables()
{
    ring_x             = _ring_x;
    ring_y             = _ring_y;
    ship_angle         = _ship_angle;
    ship_x             = _ship_x;
    ship_y             = _ship_y;
    ship_v_x           = velocity_x[2];
    ship_v_y           = velocity_y[2];
    ship_mass          = _ship_mass;
    ship_thrust        = _ship_thrust;
}

static double rand1(void)
{
    long r = random() & 0xffff;
    return ((double)r/((double)0x10000));
}

@implementation AppController
/** Close the application when the window is closed
 */
- (void) windowWillClose:(NSNotification*)notification
{
    [[NSApplication sharedApplication] terminate: self];
}

- (void) gameInit
{
    // Randomize it's angle
    _ship_angle = rand1()*360.0;
    // Randomize it's initial speed
    double speed = rand1()*1.0/32.0;
    velocity_x[0] = velocity_x[1] = velocity_x[2] = speed*cos(_ship_angle*2*M_PI/360.0);
    velocity_y[0] = velocity_y[1] = velocity_y[2] = speed*sin(_ship_angle*2*M_PI/360.0);
    // Randomize the position of the ship
    position_x[0] = position_x[1] = -0.65;
    position_y[0] = position_y[1] = rand1()*0.9-0.5;
    // Set up the ring
    _ring_x = 0.82;
    _ring_y = 0.0;
    // Set up the initial values
    [visView setInputValuesWithPropertyList:
     @{
       @"Duration": [NSNumber numberWithDouble: 0.00],
       @"ring_x"  : [NSNumber numberWithDouble: _ring_x],
       @"ring_y"  : [NSNumber numberWithDouble: _ring_y],
       @"ship_x1" : [NSNumber numberWithDouble: _ship_x],
       @"ship_y1" : [NSNumber numberWithDouble: _ship_y],
       @"ship_angle": [NSNumber numberWithDouble: _ship_angle ]
       }];
}

//startTime = CACurrentMediaTime();
//static CFTimeInterval startTime;
#define update_dT (0.10)

/** Play one round of the game
 */
- (void) playRound: (id) ignore
{

    // Set up the variables
    ship_dAngle = 0;
    ship_thrustOn=0;
    copyPlayerStateVariables();
    // Call the player's targeting procedure
    shipNavigate();
    // Duplicate the variables to prevent player cheating
    copyPlayerStateVariables();

    // Limit the change in angle to 15deg at most
    double dAngle = ship_dAngle;
    if (dAngle < -15.0) dAngle = -15.0;
    if (dAngle >  15.0) dAngle = 15.0;
    // Add to the current angle
    _ship_angle += dAngle;
    // Normalize the angle
    if (_ship_angle >= 360.0)
    _ship_angle -= 360.0*trunc(_ship_angle/360.0);
    while (_ship_angle < 0.0)
    {
        _ship_angle += 360.0;
    }
    
    // Convert to radian
    double ship_radian = _ship_angle * 2*M_PI/360.0;

    // Calculate the acceleration
    double ship_ax = 0;
    double ship_ay = 0;
    if (ship_thrustOn)
    {
        double accel = _ship_thrust/_ship_mass;
        ship_ax = cos(ship_radian) * accel;
        ship_ay = sin(ship_radian) * accel;;
    }
    acceleration_x[2] = ship_ax;
    acceleration_y[2] = ship_ay;

    // Calculate the positionof the ship
    _ship_x = doubleIntegrate(idx, position_x, velocity_x, acceleration_x, update_dT);
    _ship_y = doubleIntegrate(idx, position_y, velocity_y, acceleration_y, update_dT);
    idx = (idx + 1) %2;
    
    // compute how much we are off
    double gapx = _ship_x-_ring_x;
    gapx *= gapx;
    double gapy = _ship_y-_ring_y;
    gapy *= gapy;
    double gap = gapx+gapy;
    // Todo improve this to detect passing thru it
    int hit = gap < 0.04 ? 1 : 0;
    if (hit)
    {
        // Stop the timer
        [timer invalidate];
        timer = nil;
        [visView setValue: [NSNumber numberWithInt: hit]
              forInputKey: @"Hit"];
        [visView setValue: [NSString stringWithFormat:@"%0.1f", gameDuration]
              forInputKey: @"Seconds"];
    }

        //[visView pauseRendering];
    [visView setInputValuesWithPropertyList:
     @{
        @"Duration"  : [NSNumber numberWithDouble: update_dT*1.2],
        @"ship_x1"   : [NSNumber numberWithDouble: _ship_x],
        @"ship_y1"   : [NSNumber numberWithDouble: _ship_y],
        @"ship_angle": [NSNumber numberWithDouble: _ship_angle],
        @"Thrust"    : [NSNumber numberWithInt   : ship_thrustOn]
        }];
    
    // Keep track of how much time has passed
    gameDuration += update_dT;
}


- (void) applicationWillFinishLaunching:(NSNotification*)notification
{
    // Load the graphics part of the system
    [visView loadCompositionFromFile:
         [[NSBundle mainBundle] pathForResource:@"Fly thru Ring"
                                         ofType:@"qtz"]];
    [visView setMaxRenderingFrameRate:0.0];

    [self gameInit];

     // Create a timer to make automatic attempts to play the game
    timer = [NSTimer timerWithTimeInterval: update_dT
                                     target: self
                                   selector: @selector(playRound:)
                                   userInfo: nil
                                    repeats: true];
    [[NSRunLoop currentRunLoop] addTimer:timer
                                 forMode:NSDefaultRunLoopMode];
    
    // hide the cursor
    //CGDisplayHideCursor (kCGDirectMainDisplay);
    [visView startRendering];
}
    

@end

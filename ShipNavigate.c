//
//  ShipNavigage
//  Fly the Ship into Ring
//
//  Created by Randall Maas on 1/21/14.
//
//

/** This is the only file that you are allowed to modify*/

#include <stdio.h>
#include <math.h>

/// This is the position of the ring that the player will to fly into.
/// You can not modify it.
extern const double ring_x;
extern const double ring_y;
/// This is the ship's x position
/// You can not modify it.
extern const double ship_x;
/// This is the ship's y position
/// You can not modify it.
extern const double ship_y;
/// This is the ships orientation, in degrees
/// You can not modify it.
extern const double ship_angle;
/// This is the ship's x velocity
/// You can not modify it.
extern double ship_v_x;
/// This is the ship's y velocity
/// You can not modify it.
extern double ship_v_y;

/// This is the ship's mass
/// You can not modify it.
extern const double ship_mass;
/// This is the ship's thrust
/// You can not modify it.
extern double ship_thrust;


/// The procedure may set the variable ship_dAngle to amount it wants to change the ships
///  orientation by: -15..15 degrees.
extern double ship_dAngle;

/// The procedure is to set this if the ship's thrusters are set on
extern int ship_thrustOn;


/** This is the procedure that you customize to shoot the ball.
    Your objective is to compute angle to shoot the ball.
    @return The angle to shoot with. 0..90
 
    The procedure may set the variable ship_dAngle to amount it wants to change the ships
    orientation by: -15..15 degrees.
 */
void shipNavigate()
{
    // choose the ball shooter angle
    double dX = ring_x - ship_x;
    double dY = ring_y - ship_y;
    double dAngle = atan2(dY,dX)*360.0/(2.0*M_PI);
    if (dAngle < 0.0) dAngle += 360.0;
    ship_dAngle = dAngle-ship_angle;
    if (ship_dAngle < 5.0 && ship_dAngle > -5.0)
        ship_thrustOn = 1;
    else
        ship_thrustOn = 0;

    // This is a dumb choice
}
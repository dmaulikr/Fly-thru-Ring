Fly thru Ring
====================

This is a program to practice shooting a ball into a ring on the floor.

Demo
------

(click to see video)

[![ScreenShot](https://i.ytimg.com/vi/ZzzNkz60B9I/hqdefault.jpg)](http://www.youtube.com/watch?v=ZzzNkz60B9I)

The Task
--------

The exercise is to write a procedure **shipNavigate()** that decides how to steer the ship, and if the thrusters should
be turned on.  This procedure is supposed to set two variables:

* *ship_dAngle*  is the amount that the procedure wants to change the ships orientation angle by.  This must be in the range  -15..15 degrees.

* *ship_thrustOn* is set to 0 if the procedure wants the thrusters off, 1 if the procedure wants them on.  The ship will be accelerated in the direction that it is orientated.

The procedure has access to the global state of the game, but it is not allowed to change any.  These
state variables are:

* *ring_x*  is the x coordinate of the ring that the player will to fly into.
* *ring_y*  is the y coordinate of the ring that the player will to fly into.
* *ship_angle* is the ships orientation, in degrees
* *ship_x*   is the ship's x position
* *ship_y*   is the ship's y position
* *ship_v_x* is the ship's x velocity
* *ship_v_y* is the ship's y velocity
* *ship_mass* is the ship's mass
* *ship_thrust* if the force that will be applied to the ship, if the thrusters are on


Angles
------

The angles are oriented using the standard mathematical convention that angle 0 is at 3o'clock (on the x axis, on the right)
and that angles increases as in the counterclockwise direction.  The task uses angles in degrees.


Requirements
---------------
The was created using the Xcode editor running under Mac OS X 10.8.x or later. 


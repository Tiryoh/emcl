#!/bin/bash -e

xvfb-run -s "-screen 0 1400x900x24" bash || true

killall roslaunch || true
killall gzclient || true

roslaunch emcl test.launch &

sleep 15

rostopic pub /initialpose geometry_msgs/PoseWithCovarianceStamped "header:
  seq: 0
  stamp:
    secs: 0
    nsecs: 0
  frame_id: ''
pose:
  pose:
    position: {x: -2.5, y: 0.0, z: 0.0}
    orientation: {x: 0.0, y: 0.0, z: 0.0, w: 0.0}
  covariance: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
    0.0, 0.0, 0.0, 0.0, 0.0, 0.0]" --once 

rostopic echo /mcl_pose -n 1000 | 
grep -A2 position:             |
awk '/x:/{printf $2" "}/y:/{print $2}' |
awk '{print $0}
     sqrt( ($1+2.0)^2 + ($2+0.5)^2 ) < 0.15 {print "OK";exit(0)}
     NR==1000{print "TIMEOUT";exit(1)}'

RESULT=$?

killall roslaunch || true
killall gzclient || true

exit $RESULT

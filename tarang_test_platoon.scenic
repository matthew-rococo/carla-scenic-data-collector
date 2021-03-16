import sys
try:
    sys.path.append("./libs/carla-0.9.9-py3.7-linux-x86_64.egg")
except IndexError:
    pass

param map = localPath('maps/CARLA/Town03.xodr')  
param carla_map = 'Town03'
param weather = 'ClearNoon' 
model scenic.simulators.carla.model

# import scenic.simulators.carla.actions as actions

from scenic.core.geometry import subtractVectors

# from scenic.simulators.domains.driving.network import loadNetwork
# loadNetwork('/home/carla_challenge/Desktop/Carla/Dynamic-Scenic/CARLA_0.9.9/Unreal/CarlaUE4/Content/Carla/Maps/OpenDrive/Town03.xodr')

# from scenic.simulators.carla.model import *
# from scenic.simulators.carla.behaviors import *


"""
Dynamic version of platoon scenario from https://arxiv.org/pdf/1809.09310.pdf
"""

TRAFFIC_SPEED = 10
EGO_SPEED = 8
DISTANCE_THRESHOLD = 4
BRAKE_ACTION = (0.8, 1.0)

behavior FollowTrafficBehavior(speed):
	# print("position: ", ego.position)
	brake_intensity = resample(BRAKE_ACTION)
	try:
		FollowLaneBehavior(speed)

	interrupt when withinDistanceToAnyObjs(self, DISTANCE_THRESHOLD):
		take SetBrakeAction(brake_intensity)

def createPlatoonAt(car, numCars, model=None, dist=(2, 8), shift=(-0.5, 0.5), wiggle=0):
	lastCar = car
	for i in range(numCars-1):
		center = follow roadDirection from (front of lastCar) for Range(*dist)
		pos = OrientedPoint right of center by shift, facing resample(wiggle) relative to roadDirection
		lastCar = Car ahead of pos, with behavior FollowTrafficBehavior(TRAFFIC_SPEED)
    # add FollowLaneBehavior to lastCar


param time = (8,20) * 60
roads = network.roads
select_road = Uniform(*roads)
select_lane = Uniform(*select_road.lanes)

ego = Car on select_lane.centerline,
		 with visibleDistance 60,
		 with behavior FollowTrafficBehavior(EGO_SPEED)

c2 = Car visible
platoon = createPlatoonAt(c2, 10, dist=(2,5))

# require ego can see oncomingCar
require (distance to intersection) > 50
require (ego.laneSection._fasterLane is not None)
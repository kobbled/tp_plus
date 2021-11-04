#!/usr/bin/ruby

require_relative '../pose_factory'

TOTAL_GROUPS = 2
UFRAME = 3
UTOOL = 5
POSITION_LENGTH = 6

#start pose factory
factory = TPPlus::Motion::Factory::Pose.new(UFRAME, UTOOL)

#initialize list of poses
(1..POSITION_LENGTH).each do |i|
    name = "p#{i}"
    factory.add(name.to_sym)
end

#make a config object
config = TPPlus::Motion::HashTemplate::CONFIG.clone
config[:flip] = true
config[:up] = true
config[:top] = true

#set default pose
factory.set_default(TPPlus::Motion::Types::POSE, group: 1, components: [0,0,0,-90,0,90])
factory.set_default(TPPlus::Motion::Types::CONFIG, group: 1, components: config)
factory.set_default(TPPlus::Motion::Types::JOINTS, group: 2, components: [90,0])


factory.set_pose(:p1, TPPlus::Motion::Types::POSE, group: 1, components: [0,50,0])
factory.set_pose(:p2, TPPlus::Motion::Types::COORD, group: 1, components: [0,20,10], offset: true)

factory.set_pose(:p3, TPPlus::Motion::Types::ORIENT, group: 1, components: [0,0,90], offset: true)
factory.set_pose(:p3, TPPlus::Motion::Types::JOINTS, group: 2, components: [0,90], offset: true)

# config = TPPlus::Motion::HashTemplate::CONFIG.clone
# factory.set_default(TPPlus::Motion::Types::POSE, group: 1, components: [0,100,100,0,0,0])
# factory.set_default(TPPlus::Motion::Types::CONFIG, group: 1, components: config)
# factory.set_default(TPPlus::Motion::Types::JOINTS, group: 2, components: [[0,'mm']])
# factory.set_default(TPPlus::Motion::Types::JOINTS, group: 3, components: [0,0])

factory.set_pose(:p5, TPPlus::Motion::Types::COORD, group: 1, components: [80, 180, 300], coord: 'polar')

puts factory
#===============================================================================
# )----------------------------------------------------------------------------(
# )--     AUTHOR:     Mr Trivel                                              --(
# )--     NAME:       Animated Faces                                         --(
# )--     CREATED:    2014-09-12                                             --(
# )--     VERSION:    1.1                                                    --(
#===============================================================================
# )----------------------------------------------------------------------------(
# )--                         VERSION HISTORY                                --(
# )--  1.0 - Initial script.                                                 --(
# )--  1.1 - Fixed bugs. Uses Frames per second instead of pure frames.      --(
#===============================================================================
# )----------------------------------------------------------------------------(
# )--                          DESCRIPTION                                   --(
# )--  Allows for actor faces to be animated.                                --(
#===============================================================================
# )----------------------------------------------------------------------------(
# )--                          INSTRUCTIONS                                  --(
# )--  Define animation files and frame sequence in ANIMATED_FACES module.   --(
#===============================================================================
# )----------------------------------------------------------------------------(
# )--                          LICENSE INFO                                  --(
# )--    Free for non-commercial games if credit was given to Mr Trivel.     --(
# )----------------------------------------------------------------------------(
#===============================================================================

# )=======---------------------------------------------------------------------(
# )-- Module: ANIMATED_FACES                                                 --(
# )---------------------------------------------------------------------=======(
module ANIMATED_FACES
  # )--------------------------------------------------------------------------(
  # )-- Place your animated faces data here.                                 --(
  # )--------------------------------------------------------------------------(
  DATA = {
  # )-- ACTOR_ID    Filename      Frame Sequence                  
          1 => [ "8Cua3Mv.png", [0, 1, 2, 3, 2, 0, 0, 0, 0, 0 ,0, 0] ]
  
  }
  
  # )--------------------------------------------------------------------------(
  # )-- How fast should frames change. Speed in milliseconds.                --(
  # )--------------------------------------------------------------------------(
  FRAME_SPEED = 150
end

# )=======---------------------------------------------------------------------(
# )-- class: Window_Base                                                     --(
# )---------------------------------------------------------------------=======(
class Window_Base < Window
  include ANIMATED_FACES

  alias :mrts_face_anims_update :update
  alias :mrts_face_anims_initialize :initialize
  
  # )--------------------------------------------------------------------------(
  # )-- Alias: initialize                                                    --(
  # )--------------------------------------------------------------------------(
  def initialize(x, y, width, height)
    mrts_face_anims_initialize(x, y, width, height)
    @time_now = Time.now
    @elapsed_time = 0.0
    @actor_hash = {}
    
  end
  # )--------------------------------------------------------------------------(
  # )-- Overwrite: draw_actor_face                                           --(
  # )--------------------------------------------------------------------------(
  def draw_actor_face(actor, x, y, enabled = true)
    data = DATA[actor.id]
    if data
      @animated_actors ||= true
      @actor_hash[actor.id] ||= 0
      face_name = data[0]
      face_index = data[1][@actor_hash[actor.id]]
      draw_face(face_name, face_index, x, y, enabled)
    else
      draw_face(actor.face_name, actor.face_index, x, y, enabled)
    end
  end
  
  # )--------------------------------------------------------------------------(
  # )-- Alias: update                                                        --(
  # )--------------------------------------------------------------------------(
  def update    
    finish = Time.now
    @elapsed_time += ms(@time_now, finish)
    mrts_face_anims_update
    if @animated_actors && @elapsed_time >= FRAME_SPEED && Time.now.to_f != @time_now
      $game_party.members.each { |a|  
        @actor_hash[a.id] += 1
        @actor_hash[a.id] = 0 if @actor_hash[a.id] > DATA[a.id][1].size-1
      }
      refresh
      @elapsed_time = 0
    end
    @time_now = Time.now
  end
  
  # )--------------------------------------------------------------------------(
  # )-- New Method: ms                                                       --(
  # )--------------------------------------------------------------------------(
  def ms(start, finish)
   (finish - start) * 1000.0
  end
end
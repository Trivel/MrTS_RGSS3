#===============================================================================
# )----------------------------------------------------------------------------(
# )--     AUTHOR:     Mr Trivel                                              --(
# )--     NAME:       Animated Faces                                         --(
# )--     CREATED:    2014-09-12                                             --(
# )--     VERSION:    1.0                                                    --(
#===============================================================================
# )----------------------------------------------------------------------------(
# )--                         VERSION HISTORY                                --(
# )--  1.0 - Initial script.                                                 --(
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
  # )-- ACTOR_ID    Filename      Frame Sequence                   Anim Speed (12 - face frame will change every 12 frames)
          1 => [ "8Cua3Mv.png", [0, 1, 2, 3, 2, 0, 0, 0, 0, 0 ,0, 0], 12]
  
  }
end

# )=======---------------------------------------------------------------------(
# )-- class: Window_Base                                                     --(
# )---------------------------------------------------------------------=======(
class Window_Base < Window
  include ANIMATED_FACES
  
  alias :mrts_face_anims_update :update
  
  # )--------------------------------------------------------------------------(
  # )-- Overwrite: draw_actor_face                                           --(
  # )--------------------------------------------------------------------------(
  def draw_actor_face(actor, x, y, enabled = true)
    if actor.has_face_anim?
      @animated_actors ||= true
      data = DATA[actor.id]
      face_name = data[0]
      stuff = (actor.face_frame/data[2]).to_i
      face_index = data[1][stuff]
      draw_face(face_name, face_index, x, y, enabled)
      actor.push_frame
    else
      draw_face(actor.face_name, actor.face_index, x, y, enabled)
    end
  end
  
  # )--------------------------------------------------------------------------(
  # )-- Alias: update                                                        --(
  # )--------------------------------------------------------------------------(
  def update
    mrts_face_anims_update
    if @animated_actors
      p = false
      $game_party.members.each { |a| 
        d = (a.face_frame/DATA[a.id][2]).to_i 
        a.push_frame
        d2 = (a.face_frame/DATA[a.id][2]).to_i 
        p = true if d2 != d
      }
      refresh if p
    end
  end
end

class Game_Actor < Game_Battler
  alias :mrts_face_anims_setup :setup
  
  # )--------------------------------------------------------------------------(
  # )-- Public Instance Variables                                            --(
  # )--------------------------------------------------------------------------(
  attr_reader :face_frame
  
  # )--------------------------------------------------------------------------(
  # )-- Alias: setup                                                         --(
  # )--------------------------------------------------------------------------(
  def setup(actor_id)
    mrts_face_anims_setup(actor_id)
    @face_frame = 0
    data = ANIMATED_FACES::DATA[actor_id]
    @max_frames = data[2]*(data[1].size-1)
  end
  
  # )--------------------------------------------------------------------------(
  # )-- New Method: push_frame                                               --(
  # )--------------------------------------------------------------------------(
  def push_frame
    return unless has_face_anim?
    @face_frame += 1
    @face_frame = 0 if @face_frame > @max_frames
  end
  
  # )--------------------------------------------------------------------------(
  # )-- New Method: has_face_anim?                                           --(
  # )--------------------------------------------------------------------------(
  def has_face_anim?
    !@max_frames.nil?
  end
end
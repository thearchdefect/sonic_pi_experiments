# Sonic Pi instrumental cover of "Oblivion" by Grimes
# !!VERY FAR FROM FINISHED!!
use_random_seed 133337
use_bpm 156

#########################
# SYNTHS
#########################
define :main_synth do |synth, note|
  # Set the sound of our primary synth.
  #
  # Args:
  #   synth - synth sound to use
  #   note - single note to play (e.g. 62, :d3)
  with_synth synth do
    with_fx :lpf, cutoff: 90 do
      with_fx :echo, phase: 0.25, mix: [0,0,0,0.25].choose do  # TODO there has to be a prettier way D:
        play note,
          amp: rrand(0.8, 1.1),
          attack: 0.1,
          decay: 0.05,
          sustain_level: 0.7,
          release: 1,
          pan: rrand(-0.5, 0.5)
      end
    end
  end
  ##| sleep 0.5
end

define :synth_beat do |root|
  # Construct the main synth beat.
  #
  # Args:
  #  root - first note of the beat, used to calculate offsets
  
  pattern = [0, 0, 12, 7,
             0, 0, 0, 7,
             0, 0, 12, 7,
             0, 12, 7, 7].ring + root
  idx = 0
  pattern.length.times do
    main_synth :prophet, pattern[idx]
    main_synth :fm, pattern[idx]
    idx = idx + 1
    sleep 0.5
  end
end

define :synth_loop do
  # Main synth loop just ping pongs between d3 and b2
  # 16 beats long
  synth_beat :d3
  synth_beat :b2
end

define :aah_sound do |synth, amp|
  # Ethereal vocal bits I don't feel like singing
  #
  # Args:
  #   synth - built in synth sound to use
  #   amp - how loud to be (0, 1)
  use_synth synth
  with_fx :reverb do
    play :fs,
      amp: amp,
      attack: 0.2,
      decay_level: 0.6,
      decay: 0.2,
      pan: rrand(-0.5, 0.5),
      ##| pan: [0.5, -0.5].ring.tick,
      release: rrand(6, 8)
  end
end

define :end_synth do |note, len|
  # Look, naming is one of the two hardest
  # problems in computer science, okay? It's
  # a synth that comes in near the end.
  #
  # Args:
  #   note - note to play
  #   len - length of time (in beats) to both sustain and sleep
  use_synth :hoover
  play note, amp: 0.3, attack: 0.1, sustain: len, release: 0
  sleep len
end

define :end_synth_loop do |root|
  # Defines the pattern for this synth
  #
  # Args:
  #   root - note to calculate offsets
  pattern = [0, 1, 2, 3, 0, -2].ring
  times = [2.5, 0.5, 0.5, 0.5, 3, 1].ring
  
  # TODO I hate that I can't just use "play_pattern_timed" for this
  idx = 0
  ##| with_fx :lpf, cutoff: 70 do
  2.times do
    pattern.length.times do
      end_synth (pattern + root)[idx], times[idx]
      idx = idx + 1
    end
  end
  ##| endtests
end

define :synth3 do
  # The synth that comes in with the piano
  use_synth :square  # TODO this is a pretty poor approximation rn
  pattern = [:d3,:cs3, :a2, :fs2].ring + 12
  with_fx :lpf, cutoff: 80 do
    play_pattern_timed pattern, [0.25]
    sleep 0.5
  end
end

define :screech do
  # TODO this is a bad approximation but ehhhh fuck it
  with_fx :reverb, room: 0.5 do
    with_fx :ixi_techno, amp: 2, phase: 8, cutoff_min: 71, cutoff_max: 83 do
      with_fx :hpf, cutoff: 30 do
        use_synth :beep
        play :d5
        use_synth :blade
        play :b5
      end
      use_synth :dull_bell
      play :d4
    end
  end
end

#########################
# ALL THE FKN PIANO PARTS
#########################

define :piano1 do
  use_synth :piano
  p1 = (knit :b4, 1, :a4, 1, :fs4, 6)
  p2 = ([:fs4, :d4] * 4).ring
  pattern = p1 + p2
  pattern.length.times do
    play pattern.tick
    sleep 0.5
  end
end

define :piano2 do
  use_synth :piano
  8.times do
    play :d5
    play :b4
    sleep 0.5
  end
  p = [:d5, :cs5, :b4, :cs5, :d5]
  times = [1, 1, 1, 1, 2]
  play_pattern_timed p, times
end

define :piano3 do
  use_synth :piano
  p = (knit :cs4, 1, :d4, 3)
  3.times do
    p.length.times do
      play p.tick
      sleep 0.5
    end
  end
end

define :piano4 do
  use_synth :piano
  p = ([:b5, :a5, :fs5] * 4).ring
  p.length.times do
    play p.tick
    sleep 0.5
  end
end

define :piano5 do
  use_synth :piano
  p = ([:fs4, :fs4, :g4, :a4, :fs4])
  t = [0.5, 0.25, 0.25, 0.5, 0.5]
  4.times do
    play_pattern_timed p, t
  end
end


#########################
# DRUMS
#########################

# Soooo apparently you can define functions like this too,
# because this is quite literally Ruby... derp.
# TODO actually use this to replace my stupid drum implementation
def drum_pattern(p)
  return p.ring.tick(p) == "x"
end

# TODO abstract out all these sleep parameters

def kick(slp)
  # Set the sound of the kick(? I guess) drum
  # TODO try out different sounds for this,
  # the real one is more muted
  #
  # Args:
  #   slp - sleep time after sample
  sample :drum_heavy_kick,
    rate: 1,
    pitch_dis: 0.001
  sleep slp
end

define :snare_1 do |slp|
  # Set the sound of the first snare
  #
  # Args:
  #   slp - sleep time after sample
  sample :drum_snare_soft
  sleep slp
end

define :snare_2 do |slp|
  # Sound of the second snare
  #
  # Args:
  #   slp - sleep time after sample
  sample :drum_snare_hard,
    amp: 0.5,
    finish: 0.5
  sleep slp
end

define :common_drum_part do
  # A repeated drum part
  kick 1
  snare_1 0.5
  kick 0.5
  # Maybe echo, maybe don't
  # TODO is there a more elegant way to express this?
  if one_in(5)
    with_fx :echo, amp: 0.75, phase: 0.2, decay: 0.2, mix: 0.25 do
      kick 1
    end
  else
    kick 1
  end
end

define :main_drum_beat do
  # Construct the drum beat
  3.times do
    common_drum_part
    snare_1 1
  end
  common_drum_part
  snare_2 1
end

#########################
# VOCALS
#########################
sample_folder = "/Users/jaguarshark/personal/music/oblivion_samples"

define :main_vocs do
  verse1 = "#{sample_folder}/main_vocs.wav"  # TODO non-shitty version
  with_fx :reverb do  # TODO put more thought into effects
    sample verse1
  end
end

define :oohwahoh_x4 do
  smpl = "#{sample_folder}/oohwahoh.wav"
  with_fx :reverb do  # TODO figure out how to slide the panning around
    sample smpl
  end
end

define :la_x5 do
  smpl = "#{sample_folder}/lax5.wav"
  with_fx :reverb do
    sample smpl
  end
end

define :ooh_x5 do
  smpl = "#{sample_folder}/oohx5.wav"
  with_fx :reverb do
    sample smpl
  end
end

#########################
# THE ACTUAL SONG
#########################
v1_adjust = 0.85  # TODO just put these in the functions themselves
ooh_adjust = -4.15
# Main thread, sends cues and sleeps
in_thread do
  sleep 4  # IDK why this is necessary, but it is
  # TODO 1 bar of intro
  cue :all_vocals
  sleep 1.5385
  cue :synth_loop
  sleep 32
  cue :drum_beat
  ##| sleep 32 + v1_adjust  # Compensate for sample timing
  ##| cue :verse1
  ##| sleep 64 - v1_adjust + ooh_adjust # Add the adjustment time back in
  ##| cue :oohwahoh
  ##| sleep 12  # Don't need to adjust bc it's the same amount off as the previous one
  ##| cue :la
  ##| sleep 32 - ooh_adjust
  ##| cue :end_synth
end

# Vocal threads
in_thread do
  sync :all_vocals
  main_vocs
end

in_thread do
  sync :all_vocals
  oohwahoh_x4
end

in_thread do
  sync :all_vocals
  ooh_x5
end

in_thread do
  sync :all_vocals
  la_x5
end


# Main synth
in_thread do
  sync :synth_loop
  20.times do
    synth_loop
  end
  # TODO re-sync
end

# Drums
in_thread do
  # drum beat is 16 beats / 4 bars long
  sync :drum_beat
  14.times do
    main_drum_beat
  end
  with_fx :level, amp: 0, amp_slide: 16, amp_slide_shape: 1 do
    main_drum_beat
  end
end

# Additional synths
in_thread do
  sync :drum_beat  # Maybe I should rename this cue
  loop do
    aah_sound :sine, 0.4
    aah_sound :dsaw, 0.1
    sleep 16
  end
end

# Piano
in_thread do
  sync :piano
  # TODO make the piano parts
end

# Synth that accompanies the piano
in_thread do
  sync :piano
  4.times do
    synth3
  end
end

in_thread do
  sync :sparkles
  # TODO sparkles
end

# End synth
in_thread do
  sync :end_synth
  end_synth_loop :d3
  end_synth_loop :b2
end





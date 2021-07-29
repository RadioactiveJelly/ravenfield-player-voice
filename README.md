# ravenfield-player-voice
A mutator mod that gives the player voice reactions in Ravenfield.

Documentation for PlayerVoice v1.3
How to use:
- All you have to do is put in files in the appropriate reaction type. If you don't want to use it, you can leave it blank no problems.
- Do note, Light Damage reactions are currently unused in this version of the script. You're free to change the script if you want though.
- If you encounter any bugs or problems with making a mutator, feel free to reach out to me for assistance. I'll do my best to assist you.

- Damage Reactions
	- Has sound banks for medium and heavy damage.
	- Medium damage will override light damage below certain HP thresholds.
	- Same applies for heavy damage
	- Heavy damage automatically plays when knocked-down
        - Will interrupt most reactions
	- Light damage has been removed due to it being played rarely.
- Low Health Reactions
	- Will play when HP is below a certain HP threshold.
	- Will play once, then only play again when damaged.
	- If knocked down, this will only start playing once the player begins to stand up.
- Death Reactions
	- Self explanatory, will interrupt everything except falling if you die before hitting the ground.
- Kill Reactions
	- Will play for every kill.
- Kill Streaks
	- Will override standard kill reactions.
- Revenge Kill
	- Plays if you kill someone who's damaged you
- First Spawn Reaction
	- Plays the first time you spawn in.
- Reloading Reactions
	- Plays when you reload.
	- Interrupted by getting damaged.
	- Will not play if low health reactions are playing.
- Match End Reactions
	- Will only play if player is alive during match end.
- Capture Point Reactions
	- Taking Point reactions play if you neutralize a point owned by the enemy team.
	- Opposite applies for losing point reactions.
	- Capture Reactions play when you successfully capture a point.
- Falling Reactions
	- Plays when the player reaches a certain velocity and is ragdolled. Will not be interrupted if the player dies while falling (this is for maps like Freehold)

# Player Voice
A mutator mod that gives the player voice reactions in Ravenfield.

## Documentation for PlayerVoice v1.6.0

##### How to Use:
- Download the package and import it into your Tools Pack project.
- All you have to do is put your sound files in the appropriate sound bank on the template prefab. You can leave a sound bank empty, no problem.
- Do note, Light Damage reactions are currently unused in this version of the script. You're free to change the script if you want though.
- If you encounter any bugs or problems with making a mutator, feel free to reach out to me. I'll do my best to assist you.

##### Some Notes On Updates:
- If you're using this template, please be aware that this mod will receive updates from time to time.
- If it's a patch or bug fix (when the third number in the version goes up) all you'll have to do is update your script accordingly.
- If it's a feature update (when the second number goes up) you'll need to get the new script **and** the new template version.
- Same applies for major updates.
- Unfortunately, there isn't really a way for me to streamline the update process for you guys at the moment. I'll definitely look into it when RF moves to Unity 2020.

If you use this script and template, I'd greatly appreciate the credit. Use this url to link to my workshop page: https://steamcommunity.com/profiles/76561198065486336/myworkshopfiles/?appid=636480

##### Some Notes on Certain Reaction Types:
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

﻿-- Register the behaviour
behaviour("PlayerVoiceMutator")

--Player voice script by RadioactiveJellyfish. You're free to edit this if you need to, things that shouldn't be changed are marked. If you use this script for anything, I'd appreciate the credit.
--Thanks Sudo for implementing the Ammo/Medic bag reactions

function PlayerVoiceMutator:Awake()
	self.gameObject.name = "PlayerVoice" --DO NOT CHANGE THIS. DOING SO WILL BREAK COMPATIBILITY WITH THE QUICK THROW MUTATOR.
end

function PlayerVoiceMutator:Start()
	-- Run when behaviour is created
	GameEvents.onActorDied.AddListener(self,"onActorDied")
	GameEvents.onActorSpawn.AddListener(self,"onActorSpawn")
	GameEvents.onMatchEnd.AddListener(self,"onMatchEnd")
	GameEvents.onCapturePointCaptured.AddListener(self,"onCapturePointCaptured")
	GameEvents.onCapturePointNeutralized.AddListener(self,"onCapturePointNeutralized")

	Player.actor.onTakeDamage.AddListener(self,"onTakeDamage")
	self.gameObject.transform.SetParent(Player.actor.transform);
	self.gameObject.transform.localPosition = Vector3.zero
	
	--Also disables a reaction type if no clips are found in its soundbank.
	self.volume = self.script.mutator.GetConfigurationRange("volume")
	self.DoKillVoices = self.script.mutator.GetConfigurationBool("DoKillVoices") and #self.targets.OnKillSoundBank.clips > 0
	self.DoDamageVoices = self.script.mutator.GetConfigurationBool("DoDamageVoices")
	self.DoMatchStartVoice = self.script.mutator.GetConfigurationBool("DoMatchStartVoice") and #self.targets.OnFirstSpawnSoundBank.clips > 0
	self.KillStreakTarget = self.script.mutator.GetConfigurationInt("KillStreakTarget")
	self.DoKillStreaks = self.script.mutator.GetConfigurationBool("DoKillStreaks") and #self.targets.KillStreakSoundBank.clips > 0
	self.DoFallingVoices = self.script.mutator.GetConfigurationBool("DoFallingVoices") and #self.targets.FallingSoundBank.clips > 0
	self.DoDeathVoices = self.script.mutator.GetConfigurationBool("DoDeathVoices") and #self.targets.DeathSoundBank.clips > 0
	self.DoVictoryVoices = self.script.mutator.GetConfigurationBool("DoVictoryVoices") and #self.targets.VictorySoundBank.clips > 0
	self.DoReloadingVoices = self.script.mutator.GetConfigurationBool("DoReloadingVoices") and #self.targets.ReloadingSoundBank.clips > 0
	self.DoLossVoices = self.script.mutator.GetConfigurationBool("DoLossVoices") and #self.targets.LoseMatchSoundBank.clips > 0
	self.DoRevengeKillVoices = self.script.mutator.GetConfigurationBool("DoRevengeKillVoices") and #self.targets.RevengeKillSoundBank.clips > 0
	self.DoCaptureVoices = self.script.mutator.GetConfigurationBool("DoCaptureVoices") and #self.targets.CaptureSoundBank.clips > 0
	self.DoGrenadeReactions = self.script.mutator.GetConfigurationBool("DoGrenadeReactions") and #self.targets.ThrowGrenadeBank.clips > 0
	self.DoSmokeGrenadeReactions = self.script.mutator.GetConfigurationBool("DoSmokeGrenadeReactions") and #self.targets.SmokeGrenadeBank.clips > 0
	self.DoStunGrenadeReactions = self.script.mutator.GetConfigurationBool("DoStunGrenadeReactions") and #self.targets.StunGrenadeSoundBank.clips > 0
	self.DoAmmoBagReactions = self.script.mutator.GetConfigurationBool("DoAmmoBagReactions") and #self.targets.AmmoBagSoundBank.clips > 0
	self.DoMedicBagReactions = self.script.mutator.GetConfigurationBool("DoMedicBagReactions") and #self.targets.MedicBagSoundBank.clips > 0

	self.TimeBetweenKillReactions = self.script.mutator.GetConfigurationFloat("TimeBetweenKillReactions")

	self.weapons = {}
	self.grenades = {}

	self.isPlayingDamageSound = false
	self.isPlayingLowHealthSound = false
	self.isPlayingDeathSound = false
	self.isPlayingKillSound = false
	self.isPlayingFallingSound = false
	self.isPlayingFirstSpawnSound = false
	self.isPlayingReloadSound = false
	self.isPlayingMatchEndSound = false
	self.isPlayingCapturePointSound = false
	self.isPlayingThrowSound = false
	

	--Since low health, light, medium and heavy damage all use the same config bool, individual local booleans need to be used in case they have zero clips in their banks.
	self.doLowHealthSounds = #self.targets.LowHealthSoundBank.clips > 0
	self.doLightDamageSounds = #self.targets.LightDamageSoundBank.clips > 0
	self.doMediumDamageSounds = #self.targets.MediumDamageSoundBank.clips > 0
	self.doHeavyDamageSounds = #self.targets.HeavyDamageSoundBank.clips > 0

	self.doTakingPointVoices = #self.targets.TakingPointBank.clips > 0
	self.doLosingPointVoices = #self.targets.LosingPointBank.clips > 0

	self.targets.AudioSource.SetOutputAudioMixer(AudioMixer.FirstPerson)

	local vol = self.volume/100;
	self.targets.AudioSource.volume = vol
	
	self.lastDamageSource = nil

	self.hasPlayedLowHealth = false
	self.firstSpawn = true;
	self.maxHP = 100
	self.killCount = 0;
	self.isFalling = false;
	self.doneReloading = true;

	--Percent to be considered at low HP. Used to calculate lowHPThreshold.
	self.lowHpPercent = 0.5
	self.lowHPThreshold = 50

	--Damage values that will be considered heavy or light. Medium is anything in between these two values.
	self.heavyDamage = 60

	--Determines when the damage sound will be overrided. (i.e. if player HP < 50 it will always use the medium damage sound bank)
	self.heavyDamageOverrideThreshold = 50

	--This is to scale the above variables to the player's max HP in case it's above 100
	self.percentTodoHeavyOverride = 0.5

	self.isSpawnUiOpen = false

	--Parse the smoke grenades string.
	if(self.DoSmokeGrenadeReactions) then
		local smokeWhiteListString = self.script.mutator.GetConfigurationString("SmokeGrenades")
		self.smokeWhiteList = {}
		local smokeWhiteListCount = 1
		for word in string.gmatch(smokeWhiteListString, '([^,]+)') do
			print("<color=green>[Player Voice] Added to smoke white list: " .. word .. "</color>")
			self.smokeWhiteList[smokeWhiteListCount] = word
			smokeWhiteListCount = smokeWhiteListCount + 1
		end
	end
	
	--Parse string for stun grenades.
	if(self.DoStunGrenadeReactions) then
		local stunWhiteListString = self.script.mutator.GetConfigurationString("StunGrenades")
		self.stunGrenadeWhiteList = {}
		local stunWhiteListCount = 1
		for word in string.gmatch(stunWhiteListString, '([^,]+)') do
			print("<color=green>[Player Voice] Added to stun white list: " .. word .. "</color>")
			self.stunGrenadeWhiteList[stunWhiteListCount] = word
			stunWhiteListCount = stunWhiteListCount + 1
		end
	end

	--Parse string for ammo bags.
	if(self.DoAmmoBagReactions) then
		local ammoWhiteListString = self.script.mutator.GetConfigurationString("AmmoBags")
		self.ammoWhiteList = {}
		local ammoWhiteListCount = 1
		for word in string.gmatch(ammoWhiteListString, '([^,]+)') do
			print("<color=green>[Player Voice] Added to ammo white list: " .. word .. "</color>")
			self.ammoWhiteList[ammoWhiteListCount] = word
			ammoWhiteListCount = ammoWhiteListCount + 1
		end
	end	

	--Parse string for medic bags.
	if(self.DoMedicBagReactions) then
		local medicWhiteListString = self.script.mutator.GetConfigurationString("MedicBags")
		self.medicWhiteList = {}
		local medicWhiteListCount = 1
		for word in string.gmatch(medicWhiteListString, '([^,]+)') do
			print("<color=green>[Player Voice] Added to medic white list: " .. word .. "</color>")
			self.medicWhiteList[medicWhiteListCount] = word
			medicWhiteListCount = medicWhiteListCount + 1
		end
	end

	self.delayBeforeLowHealth = 1
	self.lowHealthTimer = 0

	self.wasKnockedDown = false
	self.lastVelocity = 0

	self.knockDownTimer = 0
	self.killTimer = 0

	print("<color=aqua>[Player Voice] Initialized v1.3</color>")
end

function PlayerVoiceMutator:resetBooleans()
	self.isPlayingDamageSound = false
	self.isPlayingLowHealthSound = false
	self.isPlayingDeathSound = false
	self.isPlayingKillSound = false
	self.isPlayingFallingSound = false
	self.isPlayingFirstSpawnSound = false
	self.isPlayingReloadSound = false
	self.isPlayingMatchEndSound = false
	self.isPlayingCapturePointSound = false
	self.isPlayingThrowSound = false
end

function PlayerVoiceMutator:Update()
	--Play falling voices if certain conditions are met.
	if not self.targets.AudioSource.isPlaying then
		self:resetBooleans()
	end

	if not self.firstSpawn then
		if SpawnUi.isOpen and not self.isSpawnUiOpen then
			self.isSpawnUiOpen = true
		elseif not SpawnUi.isOpen and self.isSpawnUiOpen then
			self.isSpawnUiOpen = false
			print("<color=yellow>[Player Voice] Finding grenades.</color>")
			self:FindGrenades()
		end
		
		if self.DoReloadingVoices and Player.actor.activeWeapon 
		and Player.actor.activeWeapon.isReloading and self.doneReloading and not Player.actor.isSeated then
			if not self.targets.AudioSource.isPlaying then
				self.targets.ReloadingSoundBank.PlayRandom()
			end
			self.isPlayingReloadSound = true
			self.doneReloading = false
		elseif Player.actor.activeWeapon and not Player.actor.activeWeapon.isReloading then
			self.doneReloading = true
		end
		
		if self.doLowHealthSounds and self.DoDamageVoices and not self.wasKnockedDown then
			if(self.lowHealthTimer < self.delayBeforeLowHealth) then
				self.lowHealthTimer = self.lowHealthTimer + Time.deltaTime
			end
			self:TryPlayLowHealth(self.lowHealthTimer >= self.delayBeforeLowHealth)
			if Player.actor.health > self.lowHPThreshold then
				self.hasPlayedLowHealth = false;
			end
		end

		if self.wasKnockedDown then
			if self.knockDownTimer < 1.5 then
				self.knockDownTimer = self.knockDownTimer + Time.deltaTime
			end
			if not Player.actor.isFallenOver then
				self.wasKnockedDown = false
			end
		end
		if(self.killTimer <= self.TimeBetweenKillReactions) then
			self.killTimer = self.killTimer + Time.deltaTime
		end
	end	
end

function PlayerVoiceMutator:FixedUpdate()
	
	if self.DoFallingVoices and Player.actor.isFallenOver and Player.actor.velocity.y <= -20 and not Player.actor.isDead and not self.isFalling and not Player.actor.isParachuteDeployed then
		self.isFalling = true
		self.targets.AudioSource.Stop()
		self.targets.FallingSoundBank.PlayRandom()
		self.isPLayingFallingSound = true
	elseif (Player.actor.velocity.y == 0 or Player.actor.isParachuteDeployed or Player.actor.isSwimming) and self.isFalling then
		if Player.actor.isParachuteDeployed or Player.actor.isSwimming then
			self.targets.AudioSource.Stop()
			self.targets.AudioSource.Play()
		end
		self.isFalling = false;
	end

	if self.doLowHealthSounds and self.DoDamageVoices and self.wasKnockedDown and self.knockDownTimer >= 1.5 then
		self:TryPlayLowHealth(self.lastVelocity == Player.actor.velocity.magnitude)
	end

	self.lastVelocity = Player.actor.velocity.magnitude
end

function PlayerVoiceMutator:TryPlayLowHealth(canPlayLowHealth)
	if canPlayLowHealth and Player.actor.health <= self.lowHPThreshold and not self.targets.AudioSource.isPlaying
	and not self.hasPlayedLowHealth and not Player.actor.isDead and Player.actor.velocity.y > -20 then
		self.hasPlayedLowHealth = true;
		self.isPlayingLowHealthSound = true
		self.targets.LowHealthSoundBank.PlayRandom()
	end
end

function PlayerVoiceMutator:onTakeDamage(actor,source,info)
	--Track last actor who did damage to player for revenge kills.
	if source then
		if self.DoRevengeKillVoices and source.team ~= Player.actor.team  then
			self.lastDamageSource = source
		end	
	end
	local balanceAfterDamage = Player.actor.balance - info.balanceDamage
	if self.DoDamageVoices and not self.isPlayingDamageSound and actor.isPlayer and (not self.targets.AudioSource.isPlaying or balanceAfterDamage < 0 or self.isPlayingLowHealthSound) 
	and actor.health > 0 and not self.firstSpawn and Player.actor.velocity.y > -20 then
		self.targets.AudioSource.Stop()
		self.hasPlayedLowHealth = false;
		if self.doHeavyDamageSounds and (info.healthDamage >= self.heavyDamage or (actor.health < self.heavyDamageOverrideThreshold and actor.health > 0) or balanceAfterDamage < 0) then
			self.targets.HeavyDamageSoundBank.PlayRandom()
		elseif self.doMediumDamageSounds and (info.healthDamage < self.heavyDamage or actor.health >= self.heavyDamageOverrideThreshold) then
			self.targets.MediumDamageSoundBank.PlayRandom()
		end

		if(balanceAfterDamage < 0) then
			self.wasKnockedDown = true
			self.knockDownTimer = 0
		end
		self.lowHealthTimer = 0
		
		self.isPlayingDamageSound = true
	end
end

function PlayerVoiceMutator:onActorDied(actor,source,isSilent)
	if self.DoDeathVoices and actor.isPlayer then
		if(actor.velocity.y > -20) then
			self.targets.AudioSource.Stop()
			self.targets.DeathSoundBank.PlayRandom()
		end
		self.weapons = {}
		for i, grenade in ipairs(self.grenades) do
			grenade.onFire.RemoveListener(self,"onFire")
		end
		self.grenades = {}
		self.killCount = 0
	elseif not actor.isPlayer and source == Player.actor and not isSilent and actor.team ~= Player.actor.team  and self.killTimer > self.TimeBetweenKillReactions then
		if not self.targets.AudioSource.isPlaying and not Player.actor.isDead and not Player.actor.isFallenOver then
			self.killCount = self.killCount + 1
			if(self.killCount >= self.KillStreakTarget and self.DoKillStreaks) then
				self.targets.KillStreakSoundBank.PlayRandom()
				self.killCount = 0
			elseif self.DoRevengeKillVoices and actor == self.lastDamageSource then
				self.targets.RevengeKillSoundBank.PlayRandom()
			elseif self.DoKillVoices then
				self.targets.OnKillSoundBank.PlayRandom()
			end
			self.isPlayingKillSound = true
			self.killTimer = 0
		end
	end
end

function PlayerVoiceMutator:onActorSpawn(actor)
	if actor.isPlayer then
		self:FindGrenades()
		if self.maxHP ~= Player.actor.maxHealth then
			self.maxHP = Player.actor.maxHealth;
			self.lowHPThreshold = self.maxHP * self.lowHpPercent;
			self.heavyDamageOverrideThreshold = self.maxHP * self.percentTodoHeavyOverride;
		end
		if self.firstSpawn then
			if self.DoMatchStartVoice then
				self.targets.OnFirstSpawnSoundBank.PlayRandom();
				self.isPlayingFirstSpawnSound = true
			end
			self.firstSpawn = false;
		end
	end
	
end

function PlayerVoiceMutator:GetRandom(audioClipCount)
	local lastIndex = 0
	lastIndex = Random.Range(0, audioClipCount)
	lastIndex = (lastIndex + Random.Range(1, audioClipCount))%(audioClipCount);
	lastIndex = Mathf.Floor(lastIndex)
	return lastIndex
end

function PlayerVoiceMutator:onMatchEnd(team)
	if not Player.actor.isDead then
		if self.DoVictoryVoices and team == Player.actor.team then
			local index = self:GetRandom(#self.targets.VictorySoundBank.clips)
			self.targets.VictorySoundBank.PlaySoundBank(index)
			self.matchEndReactionLength = self.targets.VictorySoundBank.clips[index+1].length
		end
		if self.DoLossvoices and team ~= Player.actor.team then
			local index = self:GetRandom(#self.targets.LoseMatchSoundBank.clips)
			self.targets.LoseMatchSoundBank.PlaySoundBank(index)
			self.matchEndReactionLength = self.targets.LoseMatchSoundBank.clips[index+1].length
		end
		self.isPlayingMatchEndSound = true
	end
end

function PlayerVoiceMutator:onCapturePointNeutralized(capturePoint, previousOwner)
	if Player.actor.currentCapturePoint == capturePoint and not Player.actor.isDead then
		if(self.DoCaptureVoices and not self.targets.AudioSource.isPlaying and not Player.actor.isFallenOver) then
			if self.doLosingPointVoices and Player.actor.team == previousOwner then
				self.targets.LosingPointBank.PlayRandom()
			elseif self.doTakingPointVoices and Player.actor.team ~= previousOwner then
				self.targets.TakingPointBank.PlayRandom()
			end
		end
		self.isPlayingCapturePointSound = true
	end
end

function PlayerVoiceMutator:onCapturePointCaptured(capturePoint, newOwner)
	if Player.actor.currentCapturePoint == capturePoint and Player.actor.team == newOwner and not Player.actor.isDead then
		if(self.DoCaptureVoices and not self.targets.AudioSource.isPlaying and not Player.actor.isFallenOver) then
			self.targets.CaptureSoundBank.PlayRandom()
		end
		self.isPlayingCapturePointSound = true
	end
end

function PlayerVoiceMutator:onThrow(entry)
	if not self.targets.AudioSource.isPlaying and not self.isPlayingLowHealthSound then
		if self.DoSmokeGrenadeReactions then
			for y=1, #self.smokeWhiteList, 1 do
				if(entry.name == self.smokeWhiteList[y]) then
					self.targets.SmokeGrenadeBank.PlayRandom()
					return
				end
			end
		end
		if self.DoStunGrenadeReactions then
			for y=1, #self.stunGrenadeWhiteList, 1 do
				if(entry.name == self.stunGrenadeWhiteList[y]) then
					self.targets.StunGrenadeSoundBank.PlayRandom()
					return
				end
			end
		end
		if self.DoAmmoBagReactions then
			for y=1, #self.ammoWhiteList, 1 do
				if(entry.name == self.ammoWhiteList[y]) then
					self.targets.AmmoBagSoundBank.PlayRandom()
					return
				end
			end
		end
		if self.DoMedicBagReactions then
			for y=1, #self.medicWhiteList, 1 do
				if(entry.name == self.medicWhiteList[y]) then
					self.targets.MedicBagSoundBank.PlayRandom()
					return
				end
			end
		end
		if self.DoGrenadeReactions then
			for y=0, #entry.tags, 1 do
				if(entry.tags[y] == "GRENADES" or entry.tags[y]== "Grenades") then
					self.targets.ThrowGrenadeBank.PlayRandom()
					return
				end
			end
		end
	end
end

function PlayerVoiceMutator:onFire()
	self:onThrow(CurrentEvent.listenerData)
end

function PlayerVoiceMutator:CheckForGrenadeTag(weapon)
	local grenadeCount = 0
	if(weapon.gameObject.name == "THUMPER") then return end
	for y, tag in ipairs(weapon.weaponEntry.tags) do
		if(tag == "GRENADES" or tag == "Grenades" or tag == "EQUIPMENT" or tag == "Equipment") then
			self.grenades[grenadeCount] = weapon
			self.grenades[grenadeCount].onFire.AddListener(self,"onFire", self.grenades[grenadeCount].weaponEntry)
			grenadeCount = grenadeCount + 1
		end
	end
end

function PlayerVoiceMutator:FindGrenades()
	self.weapons = {}
	self.grenades = {}
	self.weapons = Player.actor.weaponSlots
	for i, weapon in ipairs(self.weapons) do
		self:CheckForGrenadeTag(weapon)
	end
end
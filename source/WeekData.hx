package;

import haxe.Json;
import sys.FileSystem;
import sys.io.File;

using StringTools;

typedef WeekFile =
{
	var songs:Array<Dynamic>;
	var weekCharacters:Array<String>;
	var weekBackground:String;
	var weekBefore:String;
	var storyName:String;
	var weekName:String;
	var freeplayColor:Array<Int>;
	var startUnlocked:Bool;
	var hideStoryMode:Bool;
	var hideFreeplay:Bool;
}

class WeekData
{
	public static var weeksLoaded:Map<String, WeekFile> = new Map<String, WeekFile>();
	public static var weeksList:Array<String> = [];

	public static function createWeekFile():WeekFile
	{
		var weekFile:WeekFile = {
			songs: [
				["Bopeebo", "dad", [146, 113, 253]],
				["Fresh", "dad", [146, 113, 253]],
				["Dad Battle", "dad", [146, 113, 253]]
			],
			weekCharacters: ['dad', 'bf', 'gf'],
			weekBackground: 'stage',
			weekBefore: 'tutorial',
			storyName: 'Your New Week',
			weekName: 'Custom Week',
			freeplayColor: [146, 113, 253],
			startUnlocked: true,
			hideStoryMode: false,
			hideFreeplay: false
		};
		return weekFile;
	}

	public static function reloadWeekFiles(isStoryMode:Null<Bool> = false)
	{
		weeksList = [];
		weeksLoaded.clear();

		var directories:Array<String> = [Paths.mods('weeks/'), Paths.getPath('weeks/')];

		var sexList:Array<String> = CoolUtil.coolTextFile(Paths.getPath('weeks/weekList.txt'));
		for (i in 0...sexList.length)
		{
			for (j in 0...directories.length)
			{
				var fileToCheck:String = directories[j] + sexList[i] + '.json';
				if (!weeksLoaded.exists(sexList[i]))
				{
					var weekFile:WeekFile = getWeekFile(fileToCheck);
					if (weekFile != null
						&& (isStoryMode == null || (isStoryMode && !weekFile.hideStoryMode) || (!isStoryMode && !weekFile.hideFreeplay)))
					{
						weeksLoaded.set(sexList[i], weekFile);
						weeksList.push(sexList[i]);
					}
				}
			}
		}

		for (i in 0...directories.length)
		{
			var directory:String = directories[i];
			if (FileSystem.exists(directory))
			{
				for (file in FileSystem.readDirectory(directory))
				{
					var path = haxe.io.Path.join([directory, file]);
					if (!sys.FileSystem.isDirectory(path) && file.endsWith('.json'))
					{
						var weekToCheck:String = file.substr(0, file.length - 5);
						if (!weeksLoaded.exists(weekToCheck))
						{
							var weekFile:WeekFile = getWeekFile(path);
							if ((isStoryMode && !weekFile.hideStoryMode) || (!isStoryMode && !weekFile.hideFreeplay))
							{
								weeksLoaded.set(weekToCheck, weekFile);
								weeksList.push(weekToCheck);
							}
						}
					}
				}
			}
		}
	}

	static function getWeekFile(path:String):WeekFile
	{
		var rawJson:String = null;
		if (FileSystem.exists(path))
		{
			rawJson = File.getContent(path);
		}

		if (rawJson != null && rawJson.length > 0)
			return cast Json.parse(rawJson);
		return null;
	}

	//   FUNCTIONS YOU WILL PROBABLY NEVER NEED TO USE
	// To use on PlayState.hx or Highscore stuff
	public static function getWeekFileName():String
	{
		return weeksList[PlayState.storyWeek];
	}

	// Used for Discord, nothing really too relevant
	public static function getCurrentWeek():WeekFile
	{
		return weeksLoaded.get(weeksList[PlayState.storyWeek]);
	}
}

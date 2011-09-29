//
//  WineskinAppDelegate.m
//  Wineskin
//
//  Copyright 2011 by The Wineskin Project and doh123@doh123.com All rights reserved.
//  Licensed for use under the LGPL <http://www.gnu.org/licenses/lgpl-2.1.txt>
//

#import "WineskinAppDelegate.h"

@implementation WineskinAppDelegate

@synthesize window;
@synthesize winetricksList, winetricksFilteredList, winetricksSelectedList, winetricksInstalledList, winetricksCachedList;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[self setWinetricksCachedList:[NSArray array]];
	[self setWinetricksInstalledList:[NSArray array]];
	[self setWinetricksSelectedList:[NSMutableDictionary dictionary]];
	[self setWinetricksList:[NSDictionary dictionary]];
	[self setWinetricksFilteredList:[self winetricksList]];
	[waitWheel startAnimation:self];
	[busyWindow makeKeyAndOrderFront:self];
	shPIDs = [[NSMutableArray alloc] init];
	[winetricksCancelButton setEnabled:NO];
	[winetricksCancelButton setHidden:YES];
	disableButtonCounter=0;
	disableXButton=NO;
	//clear out cells in Screen Options, They need to be blank but IB likes putting them back to defaults by just opening it and resaving
	[fullscreenRootlessToggleRootlessButton setIntegerValue:0];
	[fullscreenRootlessToggleFullscreenButton setIntegerValue:0];
	[normalWindowsVirtualDesktopToggleNormalWindowsButton setIntegerValue:0];
	[normalWindowsVirtualDesktopToggleVirtualDesktopButton setIntegerValue:0];
	[forceNormalWindowsUseTheseSettingsToggleForceButton setIntegerValue:0];
	[forceNormalWindowsUseTheseSettingsToggleUseTheseSettingsButton setIntegerValue:0];	
	[self installEngine];
	[self loadAllData];
	[self loadScreenOptionsData];
	NSImage *theImage = [[NSImage alloc] initByReferencingFile:[NSString stringWithFormat:@"%@/Contents/Resources/Wineskin.icns",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]]];
	[iconImageView setImage:theImage];
	[theImage release];
	[window makeKeyAndOrderFront:self];
	[busyWindow orderOut:self];
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"]]];
}
- (void)enableButtons
{
	disableButtonCounter--;
	if (disableButtonCounter == 0) [self enableButtons];
	{
		[windowsExeTextField setEnabled:YES];
		[exeFlagsTextField setEnabled:YES];
		[menubarNameTextField setEnabled:YES];
		[versionTextField setEnabled:YES];
		[customCommandsTextField setEnabled:YES];
		[useStartExeCheckmark setEnabled:YES];
		[iconImageView setEditable:YES];
		[exeBrowseButton setEnabled:YES];
		[iconBrowseButton setEnabled:YES];
		[rebuildWrapperButton setEnabled:YES];
		[refreshWrapperButton setEnabled:YES];
		[winetricksButton setEnabled:YES];
		[customExeButton setEnabled:YES];
		[changeEngineButton setEnabled:YES];
		[updateWrapperButton setEnabled:YES];
		//[testRunButton setEnabled:YES];
		[advancedDoneButton setEnabled:YES];
		[toolRunningPI stopAnimation:self];
		[toolRunningPIText setHidden:YES];
		disableXButton=NO;
	}
}
- (void)disableButtons
{
	[windowsExeTextField setEnabled:NO];
	[exeFlagsTextField setEnabled:NO];
	[menubarNameTextField setEnabled:NO];
	[versionTextField setEnabled:NO];
	[customCommandsTextField setEnabled:NO];
	[useStartExeCheckmark setEnabled:NO];
	[iconImageView setEditable:NO];
	[exeBrowseButton setEnabled:NO];
	[iconBrowseButton setEnabled:NO];
	[rebuildWrapperButton setEnabled:NO];
	[refreshWrapperButton setEnabled:NO];
	[winetricksButton setEnabled:NO];
	[customExeButton setEnabled:NO];
	[changeEngineButton setEnabled:NO];
	[updateWrapperButton setEnabled:NO];
	//[testRunButton setEnabled:NO];
	[advancedDoneButton setEnabled:NO];
	[toolRunningPI startAnimation:self];
	[toolRunningPIText setHidden:NO];
	disableButtonCounter++;
	disableXButton=YES;
}
- (void)systemCommand:(NSString *)commandToRun withArgs:(NSArray *)args
{
	[[NSTask launchedTaskWithLaunchPath:commandToRun arguments:args] waitUntilExit];
}
- (NSString *)systemCommandWithOutputReturned:(NSString *)command
{
	FILE *fp;
	char buff[512];
	NSString *returnString = @"";
	fp = popen([command cStringUsingEncoding:NSUTF8StringEncoding], "r");
	while (fgets( buff, sizeof buff, fp))
		returnString = [NSString stringWithFormat:@"%@%@",returnString,[NSString stringWithCString:buff encoding:NSUTF8StringEncoding]];
	pclose(fp);
	//cut out trailing new line
	if ([returnString hasSuffix:@"\n"])
		returnString = [returnString substringToIndex:[returnString rangeOfString:@"\n" options:NSBackwardsSearch].location];
	return returnString;
}
- (IBAction)topMenuHelpSelected:(id)sender
{
	[helpWindow makeKeyAndOrderFront:self];
}
- (IBAction)aboutWindow:(id)sender
{
	NSDictionary* plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Info.plist",[[NSBundle mainBundle] bundlePath]]];
	[aboutWindowVersionNumber setStringValue:[plistDictionary valueForKey:@"CFBundleVersion"]];
	[plistDictionary release];
	[aboutWindow makeKeyAndOrderFront:self];
}
/* Functions deactivated, not currently being used
- (NSString *)OSVersion
{
	SInt32 majorVersion,minorVersion;
	Gestalt(gestaltSystemVersionMajor, &majorVersion);
	Gestalt(gestaltSystemVersionMinor, &minorVersion);
	return [NSString stringWithFormat:@"%d.%d",majorVersion,minorVersion];
}
- (BOOL)theOSVersionIs105
{
	if ([[self OSVersion] isEqualToString:@"10.5"]) return YES;
	return NO;
}
- (BOOL)theOSVersionIs106
{
	if ([[self OSVersion] isEqualToString:@"10.6"]) return YES;
	return NO;
}
- (BOOL)theOSVersionIs107
{
	if ([[self OSVersion] isEqualToString:@"10.7"]) return YES;
	return NO;
}
- (BOOL)theOSVersionIs107
{
	if ([[self OSVersion] isEqualToString:@"10.7"]) return YES;
	return NO;
}
*/
//*************************************************************
//******************** Main Menu Methods **********************
//*************************************************************
- (IBAction)wineskinWebsiteButtonPressed:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://wineskin.doh123.com/?"]];
}
- (IBAction)installWindowsSoftwareButtonPressed:(id)sender
{
	// have user choose install program
	//NSOpenPanel *panel = [NSOpenPanel openPanel];
	NSOpenPanel *panel = [[NSOpenPanel alloc] init];
	[panel setTitle:@"Please choose the install program"];
	[panel setPrompt:@"Choose"];
	[panel setCanChooseDirectories:NO];
	[panel setCanChooseFiles:YES];
	[panel setAllowsMultipleSelection:NO];
	// runModalForDirectory deprecated in 10.6, but only method currently working in Lion beta for this.
	int error = [panel runModalForDirectory:@"/" file:nil types:[NSArray arrayWithObjects:@"exe",@"msi",@"bat",nil]];
	//exit method if cancel pushed
	if (error == 0) return;
	//show busy window
	[busyWindow makeKeyAndOrderFront:self];
	// get rid of main window
	[window orderOut:self];
	[panel release];
	//make 1st array of .exe, .msi, and .bat files
	NSArray *filesTEMP1 = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/Contents/Resources/drive_c",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] error:nil];
	NSMutableArray *files1 = [NSMutableArray arrayWithCapacity:10];
	for (NSString *item in filesTEMP1)
		if ([item hasSuffix:@".exe"] || [item hasSuffix:@".bat"] || [item hasSuffix:@".msi"])
			[files1 addObject:item];
	//run install in Wine
	[self systemCommand:[NSString stringWithFormat:@"%@/Contents/MacOS/Wineskin",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] withArgs:[NSArray arrayWithObjects:@"WSS-installer",[[panel filenames] objectAtIndex:0],nil]];
	//make 2nd array of .exe, .msi, and .bat files
	NSArray *filesTEMP2 = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/Contents/Resources/drive_c",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] error:nil];
	NSMutableArray *files2 = [NSMutableArray arrayWithCapacity:10];
	for (NSString *item in filesTEMP2)
		if ([item hasSuffix:@".exe"] || [item hasSuffix:@".bat"] || [item hasSuffix:@".msi"])
			[files2 addObject:item];
	//get last set exe, remove nothing.exe
	NSDictionary* plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Info.plist",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]]];
	NSMutableArray *finalList = [NSMutableArray arrayWithCapacity:5];
	[finalList addObject:[plistDictionary valueForKey:@"Program Name and Path"]];
	[plistDictionary release];
	[finalList removeObject:@"nothing.exe"];
	//fill new array of new .exe, .msi, and .bat files
	for (NSString *item2 in files2)
	{
		BOOL matchFound=NO;
		for (NSString *item1 in files1)
			if (([item2 isEqualToString:item1]) || ([item2 hasPrefix:@"users/Wineskin"]) || ([item2 hasPrefix:@"windows/Installer"])) matchFound=YES;
		if (!matchFound) [finalList addObject:[NSString stringWithFormat:@"/%@",item2]];
	}
	//display warning if final array is 0 length and exit method
	if ([finalList count] == 0)
	{
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Oops!"];
		[alert setInformativeText:@"No new executables found!\n\nMaybe the installer failed...?"];
		[alert setAlertStyle:NSInformationalAlertStyle];
		[alert runModal];
		[alert release];
		[window makeKeyAndOrderFront:self];
		return;
	}
	// populate choose exe list
	[exeChoicePopUp removeAllItems];
	for (NSString *item in finalList)
		[exeChoicePopUp addItemWithTitle:item];
	//show choose exe window
	[chooseExeWindow makeKeyAndOrderFront:self];
	//close busy window
	[busyWindow orderOut:self];
	//control here will pass over to chooseExeOKButtonPressed
}
- (IBAction)chooseExeOKButtonPressed:(id)sender
{
	//use standard entry from Config tab automatically.
	[self loadAllData];
	[windowsExeTextField setStringValue:[[exeChoicePopUp selectedItem] title]];
	[self saveAllData];
	//show main menu
	[window makeKeyAndOrderFront:self];
	[chooseExeWindow orderOut:self];
}
- (IBAction)setScreenOptionsPressed:(id)sender
{
	[self loadScreenOptionsData];
	[screenOptionsWindow makeKeyAndOrderFront:self];
	[window orderOut:self];
}
- (IBAction)advancedButtonPressed:(id)sender
{
	[self loadAllData];
	[advancedWindow makeKeyAndOrderFront:self];
	[window orderOut:self];
}
//*************************************************************
//************* Screen Options window methods *****************
//*************************************************************
- (void)saveScreenOptionsData
{
	NSMutableDictionary* plistDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Info.plist",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]]];
	//gamma always set the same, set it first
	if ([gammaSlider doubleValue] == 80.0)
		[plistDictionary setValue:@"default" forKey:@"Gamma Correction"];
	else
		[plistDictionary setValue:[NSString stringWithFormat:@"%1.2f",(100.0-([gammaSlider doubleValue]-80))/100] forKey:@"Gamma Correction"];
	if ([automaticOverrideToggleAutomaticButton intValue] == 1)
	{
		//set to automatic
		[plistDictionary setValue:[NSNumber numberWithBool:YES] forKey:@"Use RandR"];
		[plistDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"Fullscreen"];
		[plistDictionary setValue:@"novdx24sleep0" forKey:@"Resolution"];
		[plistDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"force Installer to normal windows"];
	}
	else
	{
		//set to override
		[plistDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"Use RandR"];
		if ([forceNormalWindowsUseTheseSettingsToggleForceButton intValue] == 1)
			[plistDictionary setValue:[NSNumber numberWithBool:YES] forKey:@"force Installer to normal windows"];
		else
			[plistDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"force Installer to normal windows"];
		if ([fullscreenRootlessToggleRootlessButton intValue] == 1)
		{
			//set up rootless
			[plistDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"Fullscreen"];
			if ([normalWindowsVirtualDesktopToggleNormalWindowsButton intValue] == 1)
				[plistDictionary setValue:@"novdx24sleep0" forKey:@"Resolution"];
			else
				[plistDictionary setValue:[NSString stringWithFormat:@"%@x24sleep0",[[virtualDesktopResolution selectedItem] title]]  forKey:@"Resolution"];
		}
		else
		{
			//set up fullscreen
			[plistDictionary setValue:[NSNumber numberWithBool:YES] forKey:@"Fullscreen"];
			[plistDictionary setValue:[NSString stringWithFormat:@"%@x%@sleep%@",[[fullscreenResolution selectedItem] title],[[[colorDepth selectedItem] title] stringByReplacingOccurrencesOfString:@" bit" withString:@""],[[[switchPause selectedItem] title] stringByReplacingOccurrencesOfString:@" sec." withString:@""]] forKey:@"Resolution"];
		}
	}
	//write GPU info check
	if ([autoDetectGPUInfoCheckBoxButton state] == 0)
		[plistDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"Try To Use GPU Info"];
	else
		[plistDictionary setValue:[NSNumber numberWithBool:YES] forKey:@"Try To Use GPU Info"];
	[plistDictionary writeToFile:[NSString stringWithFormat:@"%@/Contents/Info.plist",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] atomically:YES];
	[plistDictionary release];
}
- (void)loadScreenOptionsData
{
	//read user.reg in to array
	NSArray *arrayToSearch = [[NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Resources/user.reg",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
	//read plist for other info
	NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Info.plist",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]]];
	//Fix decorate checkmark
	BOOL startTesting = NO;
	int enableCheck = 0; //if this gets to 2, then it is disabled, otherwise enabled
	for (NSString *item in arrayToSearch)
	{
		//only tests lines after the main line found
		if ([item hasPrefix:@"[Software\\\\Wine\\\\X11 Driver]"])
		{
			startTesting = YES;
			continue;
		}
		//if to the next entry, stop testing
		if (startTesting && [item hasPrefix:@"["]) break;
		//start testing lines here
		if (startTesting)
		{
			if ([item isEqualToString:@"\"Decorated\"=\"Y\""] || [item isEqualToString:@"\"Managed\"=\"Y\""]) break;
			else if ([item isEqualToString:@"\"Decorated\"=\"N\""] || [item isEqualToString:@"\"Managed\"=\"N\""]) enableCheck++;
		}
	}
	if (enableCheck > 1)
	{
		//check the mark
		[windowManagerCheckBoxButton setState:0];
	}
	else
	{
		//uncheck mark
		[windowManagerCheckBoxButton setState:1];
	}
	//set get GPU info check
	[autoDetectGPUInfoCheckBoxButton setState:[[plistDictionary valueForKey:@"Try To Use GPU Info"] intValue]];
	[automaticOverrideToggle deselectAllCells];
	[automaticOverrideToggle selectCellWithTag:[[plistDictionary valueForKey:@"Use RandR"] intValue]];
	if ([[plistDictionary valueForKey:@"Gamma Correction"] isEqualToString:@"default"])
		[gammaSlider setDoubleValue:80.0];
	else
		[gammaSlider setDoubleValue:(-100*[[plistDictionary valueForKey:@"Gamma Correction"] doubleValue])+180];
	//set override section stuff
	if ([automaticOverrideToggleAutomaticButton intValue] == 0)
	{
		//enable all override options
		[forceNormalWindowsUseTheseSettingsToggle setEnabled:YES];
		[fullscreenRootlessToggle setEnabled:YES];
		[normalWindowsVirtualDesktopToggle setEnabled:YES];
		[virtualDesktopResolution setEnabled:NO];
		[fullscreenResolution setEnabled:YES];
		[colorDepth setEnabled:YES];
		[switchPause setEnabled:YES];
		//on override, need to load all options
		[forceNormalWindowsUseTheseSettingsToggle deselectAllCells];
		[forceNormalWindowsUseTheseSettingsToggle selectCellWithTag:[[plistDictionary valueForKey:@"force Installer to normal windows"] intValue]];
		[fullscreenRootlessToggle deselectAllCells];
		[fullscreenRootlessToggle selectCellWithTag:fabs(1-[[plistDictionary valueForKey:@"Fullscreen"] intValue])];
		if ([fullscreenRootlessToggleRootlessButton intValue] == 1)
		{
			//do rootless options
			[fullscreenRootlesToggleTabView selectFirstTabViewItem:self];
			if ([[plistDictionary valueForKey:@"Resolution"] hasPrefix:@"novd"])
			{
				[normalWindowsVirtualDesktopToggle deselectAllCells];
				[normalWindowsVirtualDesktopToggle selectCellWithTag:1];
				[virtualDesktopResolution setEnabled:NO];
			}
			else
			{
				[virtualDesktopResolution setEnabled:YES];
				[normalWindowsVirtualDesktopToggle deselectAllCells];
				[normalWindowsVirtualDesktopToggle selectCellWithTag:0];
				if ([[plistDictionary valueForKey:@"Resolution"] hasPrefix:@"Current Resolution"])
					[virtualDesktopResolution selectItemWithTitle:@"Current Resolution"];
				else
				{
					NSArray *temp = [[plistDictionary valueForKey:@"Resolution"] componentsSeparatedByString:@"x"];
					[virtualDesktopResolution selectItemWithTitle:[NSString stringWithFormat:@"%@x%@",[temp objectAtIndex:0],[temp objectAtIndex:1]]];
				}
			}
		}
		else
		{
			//do fullscreen options
			[fullscreenRootlesToggleTabView selectLastTabViewItem:self];
			if ([[plistDictionary valueForKey:@"Resolution"] hasPrefix:@"Current Resolution"])
				[fullscreenResolution selectItemWithTitle:@"Current Resolution"];
			else
			{
				NSArray *temp = [[plistDictionary valueForKey:@"Resolution"] componentsSeparatedByString:@"x"];
				[fullscreenResolution selectItemWithTitle:[NSString stringWithFormat:@"%@x%@",[temp objectAtIndex:0],[temp objectAtIndex:1]]];
			}
			// colorDepth
			if ([[plistDictionary valueForKey:@"Resolution"] hasPrefix:@"Current Resolution"])
			{
				NSArray *temp = [[plistDictionary valueForKey:@"Resolution"] componentsSeparatedByString:@"x"];
				NSArray *temp2 = [[temp objectAtIndex:1] componentsSeparatedByString:@"sleep"];
				[colorDepth selectItemWithTitle:[NSString stringWithFormat:@"%@ bit",[temp2 objectAtIndex:0]]];
			}
			else
			{
				NSArray *temp = [[plistDictionary valueForKey:@"Resolution"] componentsSeparatedByString:@"x"];
				NSArray *temp2 = [[temp objectAtIndex:2] componentsSeparatedByString:@"sleep"];
				[colorDepth selectItemWithTitle:[NSString stringWithFormat:@"%@ bit",[temp2 objectAtIndex:0]]];
			}
			// switchPause
			NSArray *temp = [[plistDictionary valueForKey:@"Resolution"] componentsSeparatedByString:@"sleep"];
			[switchPause selectItemWithTitle:[NSString stringWithFormat:@"%@ sec.",[temp objectAtIndex:1]]];
			//fix the rootless window to a selection, so its not left blank when changed later
			[normalWindowsVirtualDesktopToggle deselectAllCells];
			[normalWindowsVirtualDesktopToggle selectCellWithTag:1];
			[virtualDesktopResolution setEnabled:NO];
		}
	}
	else
	{
		//disable all override options
		[forceNormalWindowsUseTheseSettingsToggle setEnabled:NO];
		[fullscreenRootlessToggle setEnabled:NO];
		[normalWindowsVirtualDesktopToggle setEnabled:NO];
		[virtualDesktopResolution setEnabled:NO];
		[fullscreenResolution setEnabled:NO];
		[colorDepth setEnabled:NO];
		[switchPause setEnabled:NO];
	}
	[plistDictionary release];
}
- (IBAction)doneButtonPressed:(id)sender
{
	[self saveScreenOptionsData];
	[window makeKeyAndOrderFront:self];
	[screenOptionsWindow orderOut:self];
}
- (IBAction)automaticClicked:(id)sender
{
	[forceNormalWindowsUseTheseSettingsToggle setEnabled:NO];
	[fullscreenRootlessToggle setEnabled:NO];
	[normalWindowsVirtualDesktopToggle setEnabled:NO];
	[virtualDesktopResolution setEnabled:NO];
	[fullscreenResolution setEnabled:NO];
	[colorDepth setEnabled:NO];
	[switchPause setEnabled:NO];
}
- (IBAction)overrideClicked:(id)sender
{
	[forceNormalWindowsUseTheseSettingsToggle setEnabled:YES];
	[fullscreenRootlessToggle setEnabled:YES];
	[normalWindowsVirtualDesktopToggle setEnabled:YES];
	[fullscreenResolution setEnabled:YES];
	[colorDepth setEnabled:YES];
	[switchPause setEnabled:YES];
	if ([normalWindowsVirtualDesktopToggleNormalWindowsButton intValue] == 0)
		[virtualDesktopResolution setEnabled:YES];
	else
		[virtualDesktopResolution setEnabled:NO];
}
- (IBAction)rootlessClicked:(id)sender
{
	[fullscreenRootlesToggleTabView selectFirstTabViewItem:self];
	if ([normalWindowsVirtualDesktopToggleNormalWindowsButton intValue] == 0)
		[virtualDesktopResolution setEnabled:YES];
	else
		[virtualDesktopResolution setEnabled:NO];
}
- (IBAction)fullscreenClicked:(id)sender
{
	[fullscreenRootlesToggleTabView selectLastTabViewItem:self];
}
- (IBAction)normalWindowsClicked:(id)sender
{
	[virtualDesktopResolution setEnabled:NO];
}
- (IBAction)virtualDesktopClicked:(id)sender
{
	[virtualDesktopResolution setEnabled:YES];
}
- (IBAction)gammaChanged:(id)sender
{
	if ([gammaSlider doubleValue] != 80.0)
		[self systemCommand:[NSString stringWithFormat:@"%@/Contents/Resources/WSGamma",[[NSBundle mainBundle] bundlePath]] withArgs:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%1.2f",(100.0-([gammaSlider doubleValue]-80))/100],nil]];
}
- (IBAction)windowManagerCheckBoxClicked:(id)sender
{
	// get state of checkmark, set a string to Y or N for correct writing in same code
	NSString *settingString;
	if ([windowManagerCheckBoxButton state] == 0)
		settingString = [NSString stringWithFormat:@"N"];
	else
		settingString = [NSString stringWithFormat:@"Y"];
	//read user.reg in to array
	NSArray *arrayToSearch = [[NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Resources/user.reg",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
	BOOL startTesting = NO;
	BOOL decoratedFound = NO;
	BOOL managedFound = NO;
	BOOL mainSectionFound = NO;
	NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:[arrayToSearch count]];
	for (NSString *item in arrayToSearch)
	{
		//only tests lines after the main line found
		if ([item hasPrefix:@"[Software\\\\Wine\\\\X11 Driver]"])
		{
			mainSectionFound = YES;
			startTesting = YES;
			[finalArray addObject:item];
			continue;
		}
		//start testing lines here
		if (startTesting)
		{
			if ([item isEqualToString:@"\"Decorated\"=\"Y\""] || [item isEqualToString:@"\"Decorated\"=\"N\""])
			{
				[finalArray addObject:[NSString stringWithFormat:@"\"Decorated\"=\"%@\"",settingString]];
				decoratedFound = YES;
			}
			else if ([item isEqualToString:@"\"Managed\"=\"Y\""] || [item isEqualToString:@"\"Managed\"=\"N\""])
			{
				[finalArray addObject:[NSString stringWithFormat:@"\"Managed\"=\"%@\"",settingString]];
				managedFound = YES;
			}
		}
		else
		{
			[finalArray addObject:item];
		}
		//once the 2 are changed, no longer do we need to check lines, just copy them directly.
		if (decoratedFound && managedFound) startTesting = NO;
	}
	//check if the reg entry is missing... it shouldn't be if freshly made 2.0 Beta 6 or later
	//add in lines
	if (!mainSectionFound)
	{
		[finalArray addObject:@"[Software\\\\Wine\\\\X11 Driver]"];
		[finalArray addObject:[NSString stringWithFormat:@"\"Managed\"=\"%@\"",settingString]];
		[finalArray addObject:[NSString stringWithFormat:@"\"Decorated\"=\"%@\"",settingString]];
	}
	
	//write file back out to .reg file
	NSString *regFileContents = @"";
	for (NSString *item in finalArray)
		regFileContents = [regFileContents stringByAppendingString:[item stringByAppendingString:@"\n"]];
	[regFileContents writeToFile:[NSString stringWithFormat:@"%@/Contents/Resources/user.reg",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

//*************************************************************
//********************* Advanced Menu *************************
//*************************************************************
- (IBAction)advancedMenuDoneButtonPressed:(id)sender
{
	[self saveAllData];
	[window makeKeyAndOrderFront:self];
	[advancedWindow orderOut:self];
}
- (IBAction)testRunButtonPressed:(id)sender
{
	[self saveAllData];
	[NSThread detachNewThreadSelector:@selector(runATestRun) toTarget:self withObject:nil];
}
- (void)runATestRun
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//disable buttons for a test run
	[self disableButtons];
	//run the test run
	[self systemCommand:[NSString stringWithFormat:@"%@/Contents/MacOS/Wineskin",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] withArgs:[NSArray arrayWithObjects:@"debug",nil]];
	//enable the buttons that were disabled
	[self enableButtons];
	//offer to show logs
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"No"];
	[alert setMessageText:@"Test Run Complete!"];
	[alert setInformativeText:@"Do you wish to view the Test Run Logs?"];
	[alert setAlertStyle:NSInformationalAlertStyle];
	if ([alert runModal] == NSAlertFirstButtonReturn)
	{
		[self systemCommand:@"/usr/bin/open" withArgs:[NSArray arrayWithObjects:@"-e",[NSString stringWithFormat:@"%@/Contents/Resources/Logs/LastRunX11.log",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]],nil]];
		[self systemCommand:@"/usr/bin/open" withArgs:[NSArray arrayWithObjects:@"-e",[NSString stringWithFormat:@"%@/Contents/Resources/Logs/LastRunWine.log",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]],nil]];
	}
	[alert release];
	[pool release];
}
- (IBAction)killWineskinProcessesButtonPressed:(id)sender
{
	//give warning message
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"No"];
	[alert setMessageText:@"Kill Processes, Are you Sure?"];
	[alert setInformativeText:@"This will kill all processes running named \"WineskinX11\", \"wine\", and \"wineserver\" which means it will quit any other program also using Wine, wether its in the wrapper or part of Wineskin or not."];
	[alert setAlertStyle:NSInformationalAlertStyle];
	if ([alert runModal] == NSAlertFirstButtonReturn)
	{
		//kill Wineskin WineskinX11 wine wineserver
		popen([@"killall wine" UTF8String],[@"r" UTF8String]);
		sleep(2);
		popen([@"killall wineserver" UTF8String],[@"r" UTF8String]);
		sleep(2);
		popen([@"killall WineskinX11" UTF8String],[@"r" UTF8String]);
	}
	[alert release];
}
- (IBAction)advancedHelpButtonPressed:(id)sender
{
	if ([tab indexOfTabViewItem:[tab selectedTabViewItem]] == 0)
		[configHelpWindow makeKeyAndOrderFront:self];
	else
		[toolsHelpWindow makeKeyAndOrderFront:self];
}

//*************************************************************
//*********** Advanced Menu - Configuration Tab ***************
//*************************************************************
- (void)saveAllData
{
	NSMutableDictionary* plistDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Info.plist",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]]];
	[plistDictionary setValue:[windowsExeTextField stringValue] forKey:@"Program Name and Path"];
	[plistDictionary setValue:[versionTextField stringValue] forKey:@"CFBundleShortVersionString"];
	[plistDictionary setValue:[customCommandsTextField stringValue] forKey:@"CLI Custom Commands"];
	[plistDictionary setValue:[exeFlagsTextField stringValue] forKey:@"Program Flags"];
	[plistDictionary setValue:[menubarNameTextField stringValue] forKey:@"CFBundleName"];
	[plistDictionary setValue:[wineDebugTextField stringValue] forKey:@"WINEDEBUG="];
	[plistDictionary setValue:[NSString stringWithFormat:@"%@.Wineskin.prefs",[menubarNameTextField stringValue]] forKey:@"CFBundleIdentifier"];
	if ([[useStartExeCheckmark stringValue] isEqualToString:@"0"])
		[plistDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"use start.exe"];
	else
		[plistDictionary setValue:[NSNumber numberWithBool:YES] forKey:@"use start.exe"];
	[plistDictionary writeToFile:[NSString stringWithFormat:@"%@/Contents/Info.plist",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] atomically:YES];
	[plistDictionary release];
}
- (void)loadAllData
{
	//get wrapper version and put on Advanced Page wrapperVersionText
	NSDictionary* plistDictionaryWV = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Info.plist",[[NSBundle mainBundle] bundlePath]]];
	[wrapperVersionText setStringValue:[NSString stringWithFormat:@"Wineskin %@",[plistDictionaryWV valueForKey:@"CFBundleVersion"]]];
	[plistDictionaryWV release];
	//get current engine and put it on Advanced Page engineVersionText
	if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/Contents/Frameworks/wswine.bundle/version",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]]])
	{
		NSString *currentEngineVersion = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Frameworks/wswine.bundle/version",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] encoding:NSUTF8StringEncoding error:nil];
		NSArray *currentEngineVersionArray = [currentEngineVersion componentsSeparatedByString:@"\n"];
		//change engineVersionText to engine name
		[engineVersionText setStringValue:[currentEngineVersionArray objectAtIndex:0]];
	}
	//set info from Info.plist
	NSDictionary* plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Info.plist",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]]];
	[windowsExeTextField setStringValue:[plistDictionary valueForKey:@"Program Name and Path"]];
	[versionTextField setStringValue:[plistDictionary valueForKey:@"CFBundleShortVersionString"]];
	if ([[plistDictionary valueForKey:@"CLI Custom Commands"] length] > 0)
		[customCommandsTextField setStringValue:[plistDictionary valueForKey:@"CLI Custom Commands"]];
	[exeFlagsTextField setStringValue:[plistDictionary valueForKey:@"Program Flags"]];
	[menubarNameTextField setStringValue:[plistDictionary valueForKey:@"CFBundleName"]];
	[wineDebugTextField setStringValue:[plistDictionary valueForKey:@"WINEDEBUG="]];
	[useStartExeCheckmark setState:[[plistDictionary valueForKey:@"use start.exe"] intValue]];
	NSArray *assArray = [[plistDictionary valueForKey:@"Associations"] componentsSeparatedByString:@" "];
	[extPopUpButton removeAllItems];
	for (NSString *item in assArray)
		[extPopUpButton addItemWithTitle:item];
	if ([[[extPopUpButton selectedItem] title] isEqualToString:@""])
	{
		[extMinusButton setEnabled:NO];
		[extEditButton setEnabled:NO];
	}
	else
	{
		[extMinusButton setEnabled:YES];
		[extEditButton setEnabled:YES];
	}
	[mapUserFoldersCheckBoxButton setState:[[plistDictionary valueForKey:@"Symlinks In User Folder"] intValue]];
	if ([mapUserFoldersCheckBoxButton state] == 0)
		[modifyMappingsButton setEnabled:NO];
	else
		[modifyMappingsButton setEnabled:YES];
	[disableCPUsCheckBoxButton setState:[[plistDictionary valueForKey:@"Disable CPUs"] intValue]];
	[plistDictionary release];
	NSString *x11PlistFile = [NSString stringWithFormat:@"%@/Contents/Frameworks/WSX11Prefs.plist",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]];
	NSDictionary *plistDictionary2 = [[NSDictionary alloc] initWithContentsOfFile:x11PlistFile];
	[optSendsAltCheckBoxButton setState:[[plistDictionary2 valueForKey:@"option_sends_alt"] intValue]];
	[emulateThreeButtonMouseCheckBoxButton setState:[[plistDictionary2 valueForKey:@"enable_fake_buttons"] intValue]];
	[confirmQuitCheckBoxButton setState:![[plistDictionary2 valueForKey:@"no_quit_alert"] intValue]];
	[focusFollowsMouseCheckBoxButton setState:[[plistDictionary2 valueForKey:@"wm_ffm"] intValue]];
	[plistDictionary2 release];
}
- (IBAction)windowsExeBrowseButtonPressed:(id)sender
{
	//NSOpenPanel *panel = [NSOpenPanel openPanel];
	NSOpenPanel *panel = [[NSOpenPanel alloc] init];
	[panel setTitle:@"Please choose the .exe, .msi, or .bat file that should run"];
	[panel setPrompt:@"Choose"];
	[panel setCanChooseDirectories:NO];
	[panel setCanChooseFiles:YES];
	[panel setAllowsMultipleSelection:NO];
	[panel setExtensionHidden:NO];
	[panel setTreatsFilePackagesAsDirectories:YES];
	//loop until choice is in drive_c
	BOOL inDriveC = NO;
	while (!inDriveC)
	{
		//open browse window to get .exe choice
		int error = [panel runModalForDirectory:[NSString stringWithFormat:@"%@/Contents/Resources/drive_c",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] file:nil types:[NSArray arrayWithObjects:@"exe",@"msi",@"bat",nil]];
		//exit loop if cancel pushed
		if (error == 0) break;
		if ([[[panel filenames] objectAtIndex:0] hasPrefix:[NSString stringWithFormat:@"%@/Contents/Resources/drive_c",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]]])
			inDriveC = YES;
	}
	//if cancel, return
	if (!inDriveC)
	{
		[panel release];
		return;
	}
	//write the result in windowsExeTextField, remove up through drive_c folder.
	[windowsExeTextField setStringValue:[[[panel filenames] objectAtIndex:0] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/Contents/Resources/drive_c",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] withString:@""]];
	//if it is a .bat or a .msi, check the Use Start Exe Option
	if ([[windowsExeTextField stringValue] hasSuffix:@".bat"] || [[windowsExeTextField stringValue] hasSuffix:@".msi"])
		[useStartExeCheckmark setState:1];
	[panel release];
}
- (IBAction)iconToUseBrowseButtonPressed:(id)sender
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSOpenPanel *panel = [[NSOpenPanel alloc] init];
	[panel setTitle:@"Please choose the .icns file to use in the wrapper"];
	[panel setPrompt:@"Choose"];
	[panel setCanChooseDirectories:NO];
	[panel setCanChooseFiles:YES];
	[panel setAllowsMultipleSelection:NO];
	[panel setExtensionHidden:NO];
	[panel setTreatsFilePackagesAsDirectories:YES];
	//open browse to get .icns choice
	int error = [panel runModalForDirectory:@"/" file:nil types:[NSArray arrayWithObjects:@"icns",nil]];
	//if cancel return
	if (error == 0)
	{
		[panel release];
		return;
	}
	// delete old Wineskin.icns
	[fm removeItemAtPath:[NSString stringWithFormat:@"%@/Contents/Resources/Wineskin.icns",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] error:nil];
	// copy [[panel filenames] objectAtIndex:0]] to be Wineskin.icns
	[fm copyItemAtPath:[[panel filenames] objectAtIndex:0] toPath:[NSString stringWithFormat:@"%@/Contents/Resources/Wineskin.icns",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] error:nil];
	//refresh icon showing in config tab
	NSImage *theImage = [[NSImage alloc] initByReferencingFile:[NSString stringWithFormat:@"%@/Contents/Resources/Wineskin.icns",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]]];
	[iconImageView setImage:theImage];
	[theImage release];
	//rename the .app then name it back to fix the caching issues
	[fm moveItemAtPath:[NSString stringWithFormat:@"%@",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] toPath:[NSString stringWithFormat:@"%@WineskinTempRenamer",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] error:nil];
	[fm moveItemAtPath:[NSString stringWithFormat:@"%@WineskinTempRenamer",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] toPath:[NSString stringWithFormat:@"%@",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] error:nil];
	[panel release];
	[fm release];
}
- (IBAction)extPlusButtonPressed:(id)sender
{
	[self saveAllData];
	[extExtensionTextField setStringValue:@""];
	[extCommandTextField setStringValue:[NSString stringWithFormat:@"C:%@ \"%%1\"",[[windowsExeTextField stringValue] stringByReplacingOccurrencesOfString:@"/" withString:@"\\"]]];
	[extAddEditWindow makeKeyAndOrderFront:self];
	[advancedWindow orderOut:self];
}
- (IBAction)extMinusButtonPressed:(id)sender
{
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"OK"];
	[alert addButtonWithTitle:@"Cancel"];
	[alert setMessageText:@"Remove entry?"];
	[alert setInformativeText:@"This will remove the file association, are you sure?"];
	[alert setAlertStyle:NSInformationalAlertStyle];
	if ([alert runModal] == NSAlertSecondButtonReturn)
	{
		[alert release];
		return;
	}
	[alert release];
	if ([[extPopUpButton selectedItem] title] == nil) return;
	[self saveAllData];
	[busyWindow makeKeyAndOrderFront:self];
	[advancedWindow orderOut:self];
	NSArray *arrayToSearch = [[NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Resources/system.reg",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
	NSMutableArray *finalArray =  [NSMutableArray arrayWithCapacity:[arrayToSearch count]];
	BOOL waitUntilNextKey = NO;
	for (NSString *item in arrayToSearch)
	{
		if ([item hasPrefix:[NSString stringWithFormat:@"[Software\\\\Classes\\\\.%@]",[[extPopUpButton selectedItem] title]]])
		{
			waitUntilNextKey = YES;
			continue;
		}
		else if ([item hasPrefix:[NSString stringWithFormat:@"[Software\\\\Classes\\\\%@file\\\\shell\\\\open\\\\command]",[[extPopUpButton selectedItem] title]]])
		{
			waitUntilNextKey = YES;
			continue;
		}
		if (waitUntilNextKey && [item hasPrefix:@"["]) waitUntilNextKey = NO;
		if (!waitUntilNextKey) [finalArray addObject:item];
	}
	//write file back out to .reg file
	[@"" writeToFile:[NSString stringWithFormat:@"%@/Contents/Resources/system.reg",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] atomically:NO encoding:NSUTF8StringEncoding error:nil];
	NSFileHandle *aFileHandle = [NSFileHandle fileHandleForWritingAtPath:[NSString stringWithFormat:@"%@/Contents/Resources/system.reg",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]]];
	for (NSString *item in finalArray)
	{
		[aFileHandle truncateFileAtOffset:[aFileHandle seekToEndOfFile]];
		[aFileHandle writeData:[[NSString stringWithFormat:@"%@\n",item] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	//remove entry from Info.plist
	NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Info.plist",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]]];
	NSArray *temp = [[plistDictionary valueForKey:@"Associations"] componentsSeparatedByString:@" "];
	NSMutableArray *assArray = [NSMutableArray arrayWithCapacity:[temp count]];
	[assArray addObjectsFromArray:temp];
	[assArray removeObject:[[extPopUpButton selectedItem] title]];
	NSString *newExtString = @"";
	for (NSString* item in assArray)
		newExtString = [NSString stringWithFormat:@"%@ %@",newExtString,item];
	if ([newExtString hasPrefix:@" "])
	{
		newExtString = [NSString stringWithFormat:@"WineskinRemover99%@",newExtString];
		newExtString = [newExtString stringByReplacingOccurrencesOfString:@"WineskinRemover99 " withString:@""];
	}
	[plistDictionary setValue:newExtString forKey:@"Associations"];
	[plistDictionary writeToFile:[NSString stringWithFormat:@"%@/Contents/Info.plist",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] atomically:YES];
	[plistDictionary release];
	[self loadAllData];
	[advancedWindow makeKeyAndOrderFront:self];
	[busyWindow orderOut:self];	
}
- (IBAction)extEditButtonPressed:(id)sender
{
	[self saveAllData];
	// get selected extension
	[extExtensionTextField setStringValue:[[extPopUpButton selectedItem] title]];
	// read system.reg and find command line for that extension
	NSArray *arrayToSearch = [[NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Resources/system.reg",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
	NSString *lastLine = @"";
	for (NSString *item in arrayToSearch)
	{
		if ([lastLine hasPrefix:[NSString stringWithFormat:@"[Software\\\\Classes\\\\%@file\\\\shell\\\\open\\\\command]",[extExtensionTextField stringValue]]])
		{
			NSString *temp1 = [item stringByReplacingOccurrencesOfString:@"\\\"" withString:@"WINESKINTEMPBACKSLASHQUOTE"];
			temp1 = [temp1 stringByReplacingOccurrencesOfString:@"@=\"" withString:@""];
			temp1 = [temp1 stringByReplacingOccurrencesOfString:@"\"" withString:@""];
			temp1 = [temp1 stringByReplacingOccurrencesOfString:@"WINESKINTEMPBACKSLASHQUOTE" withString:@"\""];
			temp1 = [temp1 stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
			[extCommandTextField setStringValue:temp1];
			break;
		}
		lastLine = item;
	}
	[extAddEditWindow makeKeyAndOrderFront:self];
	[advancedWindow orderOut:self];
}
//*************************************************************
//*************** Advanced Menu - Options Tab *****************
//*************************************************************
- (IBAction)optSendsAltCheckBoxButtonPressed:(id)sender;
{
	NSString *x11PlistFile = [NSString stringWithFormat:@"%@/Contents/Frameworks/WSX11Prefs.plist",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]];
	NSMutableDictionary *plistDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:x11PlistFile];
	if ([optSendsAltCheckBoxButton state] == 0)
		[plistDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"option_sends_alt"];
	else
		[plistDictionary setValue:[NSNumber numberWithBool:YES] forKey:@"option_sends_alt"];
	[plistDictionary writeToFile:x11PlistFile atomically:YES];
	[plistDictionary release];
}
- (IBAction)emulateThreeButtonMouseCheckBoxButtonPressed:(id)sender
{
	NSString *x11PlistFile = [NSString stringWithFormat:@"%@/Contents/Frameworks/WSX11Prefs.plist",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]];
	NSMutableDictionary *plistDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:x11PlistFile];
	if ([emulateThreeButtonMouseCheckBoxButton state] == 0)
		[plistDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"enable_fake_buttons"];
	else
		[plistDictionary setValue:[NSNumber numberWithBool:YES] forKey:@"enable_fake_buttons"];
	[plistDictionary writeToFile:x11PlistFile atomically:YES];
	[plistDictionary release];
}
- (IBAction)mapUserFoldersCheckBoxButtonPressed:(id)sender
{
	NSMutableDictionary* plistDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Info.plist",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]]];
	if ([mapUserFoldersCheckBoxButton state] == 0)
	{
		[modifyMappingsButton setEnabled:NO];
		[plistDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"Symlinks In User Folder"];
	}
	else
	{
		[modifyMappingsButton setEnabled:YES];
		[plistDictionary setValue:[NSNumber numberWithBool:YES] forKey:@"Symlinks In User Folder"];
	}
	[plistDictionary writeToFile:[NSString stringWithFormat:@"%@/Contents/Info.plist",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] atomically:YES];
	[plistDictionary release];
}
- (IBAction)confirmQuitCheckBoxButtonPressed:(id)sender
{
	NSMutableDictionary* plistDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Frameworks/WSX11Prefs.plist",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]]];
	if ([confirmQuitCheckBoxButton state] == 0)
		[plistDictionary setValue:[NSNumber numberWithBool:YES] forKey:@"no_quit_alert"];
	else
		[plistDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"no_quit_alert"];
	[plistDictionary writeToFile:[NSString stringWithFormat:@"%@/Contents/Frameworks/WSX11Prefs.plist",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] atomically:YES];
	[plistDictionary release];
}
- (IBAction)focusFollowsMouseCheckBoxButtonPressed:(id)sender
{
	NSString *x11PlistFile = [NSString stringWithFormat:@"%@/Contents/Frameworks/WSX11Prefs.plist",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]];
	NSMutableDictionary *plistDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:x11PlistFile];
	if ([focusFollowsMouseCheckBoxButton state] == 0)
		[plistDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"wm_ffm"];
	else
		[plistDictionary setValue:[NSNumber numberWithBool:YES] forKey:@"wm_ffm"];
	[plistDictionary writeToFile:x11PlistFile atomically:YES];
	[plistDictionary release];
}
- (IBAction)modifyMappingsButtonPressed:(id)sender
{
	NSDictionary* plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Info.plist",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]]];
	[modifyMappingsMyDocumentsTextField setStringValue:[plistDictionary valueForKey:@"Symlink My Documents"]];
	[modifyMappingsDesktopTextField setStringValue:[plistDictionary valueForKey:@"Symlink Desktop"]];
	[modifyMappingsMyVideosTextField setStringValue:[plistDictionary valueForKey:@"Symlink My Videos"]];
	[modifyMappingsMyMusicTextField setStringValue:[plistDictionary valueForKey:@"Symlink My Music"]];
	[modifyMappingsMyPicturesTextField setStringValue:[plistDictionary valueForKey:@"Symlink My Pictures"]];
	[modifyMappingsWindow makeKeyAndOrderFront:self];
	[advancedWindow orderOut:self];
	[plistDictionary release];
}
- (IBAction)disableCPUsButtonPressed:(id)sender
{
	NSString *plistFile = [NSString stringWithFormat:@"%@/Contents/Info.plist",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]];
	NSMutableDictionary *plistDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFile];
	if ([disableCPUsCheckBoxButton state] == 0)
		[plistDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"Disable CPUs"];
	else
		[plistDictionary setValue:[NSNumber numberWithBool:YES] forKey:@"Disable CPUs"];
	[plistDictionary writeToFile:plistFile atomically:YES];
	[plistDictionary release];
}

//*************************************************************
//**************** Advanced Menu - Tools Tab ******************
//*************************************************************
- (IBAction)winecfgButtonPressed:(id)sender
{
	[NSThread detachNewThreadSelector:@selector(runWinecfg) toTarget:self withObject:nil];
}
- (void)runWinecfg
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self disableButtons];
	[self systemCommand:[NSString stringWithFormat:@"%@/Contents/MacOS/Wineskin",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] withArgs:[NSArray arrayWithObjects:@"WSS-winecfg",nil]];
	[self enableButtons];
	[pool release];
}
- (IBAction)uninstallerButtonPressed:(id)sender
{
	[NSThread detachNewThreadSelector:@selector(runUninstaller) toTarget:self withObject:nil];
}
- (void)runUninstaller
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self disableButtons];
	[self systemCommand:[NSString stringWithFormat:@"%@/Contents/MacOS/Wineskin",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] withArgs:[NSArray arrayWithObjects:@"WSS-uninstaller",nil]];
	[self enableButtons];
	[pool release];
}
- (IBAction)regeditButtonPressed:(id)sender
{
	[NSThread detachNewThreadSelector:@selector(runRegedit) toTarget:self withObject:nil];
}
- (void)runRegedit
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self disableButtons];
	[self systemCommand:[NSString stringWithFormat:@"%@/Contents/MacOS/Wineskin",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] withArgs:[NSArray arrayWithObjects:@"WSS-regedit",nil]];
	[self enableButtons];
	[pool release];
}
- (IBAction)taskmgrButtonPressed:(id)sender
{
	[NSThread detachNewThreadSelector:@selector(runTaskmgr) toTarget:self withObject:nil];
}
- (void)runTaskmgr
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self disableButtons];
	[self systemCommand:[NSString stringWithFormat:@"%@/Contents/MacOS/Wineskin",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] withArgs:[NSArray arrayWithObjects:@"WSS-taskmgr",nil]];
	[self enableButtons];
	[pool release];
}
- (IBAction)rebuildWrapperButtonPressed:(id)sender
{
	NSFileManager *fm = [NSFileManager defaultManager];
	//issue warning
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"No"];
	[alert setMessageText:@"***WARNING!!!!***"];
	[alert setInformativeText:@"This will remove all contents, including anything installed in drive_c, and registry files, and rebuild them from scratch!  You will lose anything you have installed in the wrapper!\n\nThis data is NOT recoverable!!\n\nAre you sure you want to do this?"];
	[alert setAlertStyle:NSInformationalAlertStyle];
	if ([alert runModal] == NSAlertFirstButtonReturn)
	{
		//delete files
		[busyWindow makeKeyAndOrderFront:self];
		[advancedWindow orderOut:self];
		[fm removeItemAtPath:[NSString stringWithFormat:@"%@/Contents/Resources/.update-timestamp",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] error:nil];
		[fm removeItemAtPath:[NSString stringWithFormat:@"%@/Contents/Resources/drive_c",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] error:nil];
		[fm removeItemAtPath:[NSString stringWithFormat:@"%@/Contents/Resources/dosdevices",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] error:nil];
		[fm removeItemAtPath:[NSString stringWithFormat:@"%@/Contents/Resources/harddiskvolume0",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] error:nil];
		[fm removeItemAtPath:[NSString stringWithFormat:@"%@/Contents/Resources/system.reg",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] error:nil];
		[fm removeItemAtPath:[NSString stringWithFormat:@"%@/Contents/Resources/user.reg",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] error:nil];
		[fm removeItemAtPath:[NSString stringWithFormat:@"%@/Contents/Resources/userdef.reg",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] error:nil];
		[fm removeItemAtPath:[NSString stringWithFormat:@"%@/Contents/Resources/winetricksInstalled.plist",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] error:nil];
		//refresh
		[self systemCommand:[NSString stringWithFormat:@"%@/Contents/MacOS/Wineskin",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] withArgs:[NSArray arrayWithObjects:@"WSS-wineprefixcreate",nil]];
		[advancedWindow makeKeyAndOrderFront:self];
		[busyWindow orderOut:self];
	}
	[alert release];
	[fm release];
}
- (IBAction)refreshWrapperButtonPressed:(id)sender
{
	[busyWindow makeKeyAndOrderFront:self];
	[advancedWindow orderOut:self];
	[self systemCommand:[NSString stringWithFormat:@"%@/Contents/MacOS/Wineskin",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] withArgs:[NSArray arrayWithObjects:@"WSS-wineprefixcreatenoregs",nil]];
	[advancedWindow makeKeyAndOrderFront:self];
	[busyWindow orderOut:self];
}
- (IBAction)winetricksButtonPressed:(id)sender
{
	/*  Winetricks adding support for having spaces... commenting out check for spaces code for now.
	if ([[[[NSBundle mainBundle] bundlePath] componentsSeparatedByString:@" "] count] > 1)
	{
		//there are spaces in the path/name, give error and return
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Error!"];
		[alert setInformativeText:@"Cannot run Winetricks.\n\nThe Winetricks script will usually fail (or mess up badly) if the path to the wrapper location, or the wrapper name, has a space in it.\n\nPlease close Wineskin, temporarily move and/or rename your wrapper, and try again.\n\nIf you take spaces out of the wrapper name, you can put the spaces back in when you are done with Winetricks, it only affects Winetricks while its running.\n\nPlease do not rename/move anything while the wrapper, or Wineskin.app is running, or it will lead to crashes."];
		[alert setAlertStyle:NSInformationalAlertStyle];
		[alert runModal];
		[alert release];
		return;
	}
	 */
	[self winetricksRefreshButtonPressed:self];
	[winetricksTabView selectTabViewItem:winetricksTabList];
}
- (IBAction)winetricksDoneButtonPressed:(id)sender
{
	[advancedWindow makeKeyAndOrderFront:self];
	[winetricksWindow orderOut:self];
}
- (IBAction)winetricksRefreshButtonPressed:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *list = nil;
	[busyWindow makeKeyAndOrderFront:self];
	[advancedWindow orderOut:self];
	[winetricksWindow orderOut:self];
	[winetricksCustomLine setStringValue:@""];
	[winetricksCustomCheckbox setState:NO];
	[self winetricksCustomCommandToggled:winetricksCustomCheckbox];
//	[[self winetricksSelectedList] removeAllObjects];

	[winetricksTableColumnInstalled setHidden:![defaults boolForKey:@"InstalledColumnShown"]];
	[winetricksTableColumnDownloaded setHidden:![defaults boolForKey:@"DownloadedColumnShown"]];
	[winetricksShowDownloadedColumn setState:([defaults boolForKey:@"DownloadedColumnShown"] ? NSOnState : NSOffState)];
	[winetricksShowInstalledColumn setState:([defaults boolForKey:@"InstalledColumnShown"] ? NSOnState : NSOffState)];
	[winetricksOutlineView setOutlineTableColumn:winetricksTableColumnName];

	// List of all winetricks
	list = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Resources/winetricksHelpList.plist",[[NSBundle mainBundle] bundlePath]]];
	BOOL needsListRebuild = NO;
	if (list == nil)
		needsListRebuild = YES;
	for (NSString *eachCategory in [list allKeys])
	{
		if ([list valueForKey:eachCategory] == nil || ![[list valueForKey:eachCategory] isKindOfClass:[NSDictionary class]])
		{
			needsListRebuild = YES;
			break;
		}
		NSDictionary *thisCategory = [list valueForKey:eachCategory];
		for (NSString *eachPackage in [thisCategory allKeys])
		{
			if ([thisCategory valueForKey:eachPackage] == nil || ![[thisCategory valueForKey:eachPackage] isKindOfClass:[NSDictionary class]])
			{
				needsListRebuild = YES;
				break;
			}
			NSDictionary *thisPackage = [thisCategory valueForKey:eachPackage];
			if ([thisPackage valueForKey:@"WS-Name"] == nil || ![[thisPackage valueForKey:@"WS-Name"] isKindOfClass:[NSString class]]
			    ||[thisPackage valueForKey:@"WS-Description"] == nil || ![[thisPackage valueForKey:@"WS-Description"] isKindOfClass:[NSString class]])
			{
				needsListRebuild = YES;
				break;
			}
		}
	}
	if (needsListRebuild)
	{ // Invalid or missing list.  Rebuild it
		[self systemCommand:[NSString stringWithFormat:@"%@/Contents/MacOS/Wineskin",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] withArgs:[NSArray arrayWithObjects:@"WSS-winetricks",@"list",nil]];
		NSArray *winetricksCategories = [[[NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Resources/Logs/Winetricks.log",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
		list = [NSMutableDictionary dictionaryWithCapacity:[winetricksCategories count]];
		for (NSString *eachCategory in winetricksCategories)
		{
			//skip if its not needed
			if (eachCategory.length == 0)
				continue;
			//run winetricks to get list of packages in current verb into winetricksTempList
			[self systemCommand:[NSString stringWithFormat:@"%@/Contents/MacOS/Wineskin",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] withArgs:[NSArray arrayWithObjects:@"WSS-winetricks", eachCategory, @"list", nil]];
			//before reading in the log, we need to find out if its iso-8859-1 which happens with some weird symbols Winetricks uses
			NSString *logContents;
			if ([[self systemCommandWithOutputReturned:[NSString stringWithFormat:@"file --mime-encoding \"%@/Contents/Resources/Logs/Winetricks.log\"",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]]] hasSuffix:@"iso-8859-1"]) //need to convert to UTF8
				logContents = [self systemCommandWithOutputReturned:[NSString stringWithFormat:@"iconv -f iso-8859-1 -t utf-8 \"%@/Contents/Resources/Logs/Winetricks.log\"",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]]];
			else
				logContents = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Resources/Logs/Winetricks.log",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] usedEncoding:nil error:nil];
			NSArray *winetricksTempList = [[logContents componentsSeparatedByString:@"\n"] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
			NSMutableDictionary *winetricksThisCategoryList = [NSMutableDictionary dictionaryWithCapacity:20];
			for (NSString *eachPackage in winetricksTempList)
			{
				NSRange position = [eachPackage rangeOfString:@" "];
				if (position.location == NSNotFound) // Skip invalid entries
					continue;
				NSString *packageName = [eachPackage substringToIndex:position.location];
				NSString *packageDescription = [[eachPackage substringFromIndex:position.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				// Yes, we're inserting the name twice (as a key and as a value) on purpose, so that we won't have to do a nasty, slow allObjectsForKey when drawing the UI.
				[winetricksThisCategoryList setValue:[NSDictionary dictionaryWithObjectsAndKeys:packageName, @"WS-Name", packageDescription, @"WS-Description", nil] forKey:packageName];
			}
			if ([winetricksThisCategoryList count] == 0)
				continue;
			[list setValue:winetricksThisCategoryList forKey:eachCategory];
		}
		[list writeToFile:[NSString stringWithFormat:@"%@/Contents/Resources/winetricksHelpList.plist",[[NSBundle mainBundle] bundlePath]] atomically:YES];
	}
	[self setWinetricksList:list];
	[self setWinetricksFilteredList:list];

	if ([defaults boolForKey:@"InstalledColumnShown"])
	{
		// List of installed winetricks
		list = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Resources/winetricksInstalled.plist",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]]];
		if ([list valueForKey:@"WS-Installed"] == nil || ![[list valueForKey:@"WS-Installed"] isKindOfClass:[NSArray class]])
		{ // Invalid or missing list.  Rebuild it
			[self systemCommand:[NSString stringWithFormat:@"%@/Contents/MacOS/Wineskin", [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] withArgs:[NSArray arrayWithObjects:@"WSS-winetricks", @"list-installed", nil]];
			NSArray *tempList = [[[NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Resources/Logs/Winetricks.log", [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
			list = [NSDictionary dictionaryWithObject:tempList forKey:@"WS-Installed"];
			[list writeToFile:[NSString stringWithFormat:@"%@/Contents/Resources/winetricksInstalled.plist",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] atomically:YES];
		}
		[self setWinetricksInstalledList:[list valueForKey:@"WS-Installed"]];
	}
	else
		[self setWinetricksInstalledList:[NSDictionary dictionary]];

	if ([defaults boolForKey:@"DownloadedColumnShown"])
	{
		// List of downloaded winetricks
		list = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/winetricks/winetricksCached.plist", [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]]];
		if ([list valueForKey:@"WS-Cached"] == nil || ![[list valueForKey:@"WS-Cached"] isKindOfClass:[NSArray class]])
		{ // Invalid or missing list.  Rebuild it
			[self systemCommand:[NSString stringWithFormat:@"%@/Contents/MacOS/Wineskin",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] withArgs:[NSArray arrayWithObjects:@"WSS-winetricks",@"list-cached",nil]];
			NSArray *tempList = [[[NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Resources/Logs/Winetricks.log", [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
			list = [NSDictionary dictionaryWithObject:tempList forKey:@"WS-Cached"];
			[list writeToFile:[NSString stringWithFormat:@"%@/winetricks/winetricksCached.plist", [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]] atomically:YES];
		}
		[self setWinetricksCachedList:[list valueForKey:@"WS-Cached"]];
	}
	else
		[self setWinetricksCachedList:[NSDictionary dictionary]];

	[winetricksOutlineView reloadData];
	//fix windows
	[winetricksWindow makeKeyAndOrderFront:self];
	[busyWindow orderOut:self];
}
- (IBAction)winetricksUpdateButtonPressed:(id)sender
{
	//Get the URL where winetricks is located
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://wineskin.doh123.com/WineskinWinetricks/Location.txt?%@",[[NSNumber numberWithLong:rand()] stringValue]]];
	NSString *urlWhereWinetricksIs = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
	urlWhereWinetricksIs = [urlWhereWinetricksIs stringByReplacingOccurrencesOfString:@"\n" withString:@""]; //remove \n
	//confirm update
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"OK"];
	[alert addButtonWithTitle:@"Cancel"];
	[alert setMessageText:@"Please confirm..."];
	[alert setInformativeText:[NSString stringWithFormat:@"Are you sure you want to update to the latest version of Winetricks?\n\nThe latest version from...\n\t%@\nwill be downloaded and installed for this wrapper.",urlWhereWinetricksIs]];
	[alert setAlertStyle:NSInformationalAlertStyle];
	if ([alert runModal] == NSAlertSecondButtonReturn)
	{
		[alert release];
		return;
	}
	[alert release];
	urlWhereWinetricksIs = [NSString stringWithFormat:@"%@?%@",urlWhereWinetricksIs,[[NSNumber numberWithLong:rand()] stringValue]]; //random added to force recheck
	//show busy window
	[busyWindow  makeKeyAndOrderFront:self];
	//hide Winetricks window
	[winetricksWindow orderOut:self];
	//Use downloader to download
	NSData *newVersion = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlWhereWinetricksIs]];
	//if new version looks messed up, prompt the download failed, and exit.
	if ([newVersion length] < 50)
	{
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Cannot Update!!"];
		[alert setInformativeText:@"Connection to the website failed.  The site is either down currently, or there is a problem with your internet connection."];
		[alert setAlertStyle:NSInformationalAlertStyle];
		[alert runModal];
		[alert release];
		[winetricksWindow makeKeyAndOrderFront:self];
		[busyWindow orderOut:self];
		return;
	}
	//delete old version
	[[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/Contents/Resources/winetricks",[[NSBundle mainBundle] bundlePath]] error:nil];
	//write new version to correct spot
	[newVersion writeToFile:[NSString stringWithFormat:@"%@/Contents/Resources/winetricks",[[NSBundle mainBundle] bundlePath]] atomically:YES];
	//chmod 755 new version
	[self systemCommand:@"/bin/chmod" withArgs:[NSArray arrayWithObjects:@"777",[NSString stringWithFormat:@"%@/Contents/Resources/winetricks",[[NSBundle mainBundle] bundlePath]],nil]];
	//remove old list of packages and descriptions (it'll be rebuilt when refreshing the list)
	[[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/Contents/Resources/winetricksHelpList.plist",[[NSBundle mainBundle] bundlePath]] error:nil];

	//refresh window
	[self winetricksRefreshButtonPressed:self];
}
- (IBAction)winetricksRunButtonPressed:(id)sender
{
	// Clean list from unselected entries
	for (NSString *eachPackage in [[self winetricksSelectedList] allKeys])
	{
		if (![[self winetricksSelectedList] valueForKey:eachPackage] || ![[[self winetricksSelectedList] valueForKey:eachPackage] boolValue]) // Cleanup
			[[self winetricksSelectedList] removeObjectForKey:eachPackage];
	}
	if ([winetricksCustomCheckbox state]) // Don't run if there are no selected packages to install
	{
		if ([[winetricksCustomLine stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
			return;
	}
	else
	{
		if ([[self winetricksSelectedList] count] == 0)
			return;
	}

	// Ask for confirmation before running winetricks
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"Run"];
	[alert addButtonWithTitle:@"Cancel"];
	[alert setMessageText:@"Do you wish to run winetricks?"];
	[alert setInformativeText:[NSString stringWithFormat:@"The following command will be executed:\nwinetricks %@", ([winetricksCustomCheckbox state] ? [[winetricksCustomLine stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] : [[[self winetricksSelectedList] allKeys] componentsJoinedByString:@" "])]];
	[alert setAlertStyle:NSInformationalAlertStyle];
	if ([alert runModal] != NSAlertFirstButtonReturn)
	{
		[alert release];
		return;
	}
	[alert release];

	winetricksDone = NO;
	winetricksCanceled = NO;
	// disable X button
	disableXButton = YES;
	// disable all buttons on Winetricks window
	[winetricksRunButton setEnabled:NO];
	[winetricksUpdateButton setEnabled:NO];
	[winetricksRefreshButton setEnabled:NO];
	[winetricksDoneButton setEnabled:NO];
	//enable cancel button
	[winetricksCancelButton setHidden:NO];
	[winetricksCancelButton setEnabled:YES];
	// start prog wheel
	[winetricksWaitWheel startAnimation:self];
	// switch to the log tab
	[winetricksTabView selectTabViewItem:winetricksTabLog];
	// delete log file
	[[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/Contents/Resources/Logs/Winetricks.log",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] error:nil];
	//killing sh processes from Winetricks will cancel out Winetricks correctly
	//get first list of running "sh" processes
	NSArray *firstPIDlist = [self makePIDArray:@"sh"];
	// call runWinetrick in new thread
	[NSThread detachNewThreadSelector:@selector(runWinetrick) toTarget:self withObject:nil];
	[NSThread detachNewThreadSelector:@selector(updateWinetrickOutput) toTarget:self withObject:nil];
	//clear out shPIDs
	[shPIDs removeAllObjects];
	//loop though a second list and matching pids several times to try and get all the correct "sh" processes.  Sadly this may get stray other processes on the system if people are multitasking a lot... not sure how else to handle it.
	int i;
	for (i=0;i<3;i++)
	{
		//get second list of running "sh" processes
		NSArray *secondPIDlist = [self makePIDArray:@"sh"];
		//compare first and second list, and ones in second list are the Winetricks ones, if cancel button pressed these are the ones to kill
		BOOL match = YES;
		for (NSString *secondPIDlistItem in secondPIDlist)
		{
			match = NO;
			for (NSString *firstPIDlistItem in firstPIDlist)
				if ([secondPIDlistItem isEqualToString:firstPIDlistItem]) match = YES;
			if (!match) [shPIDs addObject:secondPIDlistItem];
		}
		usleep(1000000);
	}
}
- (IBAction)winetricksCancelButtonPressed:(id)sender
{
	//confirm to kill with big warning window
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"Yes, do the cancel"];
	[alert addButtonWithTitle:@"I changed my mind..."];
	[alert setMessageText:@"Are You Sure?"];
	[alert setInformativeText:@"Are you sure you want to cancel Winetricks?\n\nThis will kill the running Winetricks process, but has a chance to accidently leave \"sh\" processes running until you manually end them or reboot\n\nIt could also mess up the wrapper where you may need to do a full rebuild to get it working right again (this will not usually be a problem)."];
	[alert setAlertStyle:NSInformationalAlertStyle];
	if ([alert runModal] == NSAlertSecondButtonReturn)
	{
		[alert release];
		return;
	}
	[alert release];	
	[winetricksCancelButton setHidden:YES];
	[winetricksCancelButton setEnabled:NO];
	//kill shPIDs
	winetricksCanceled = YES;
	char *tmp;
	for (NSString *item in shPIDs)
		kill((pid_t)(strtoimax([item UTF8String], &tmp, 10)), 9);	
}
- (IBAction)winetricksSelectAllButtonPressed:(id)sender
{
	for (NSDictionary *eachCategoryList in [[self winetricksFilteredList] allValues])
		for (NSString *eachPackage in eachCategoryList)
			[[self winetricksSelectedList] setValue:[NSNumber numberWithBool:YES] forKey:eachPackage];
	[winetricksOutlineView setNeedsDisplay];
}
- (IBAction)winetricksSelectNoneButtonPressed:(id)sender
{
	[[self winetricksSelectedList] removeAllObjects];
	[winetricksOutlineView setNeedsDisplay];
}
- (IBAction)winetricksSearchFilter:(id)sender
{
	NSString *searchString = [[sender stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if ([searchString length] == 0)
		[self setWinetricksFilteredList:[self winetricksList]];
	else
	{
		NSMutableDictionary *list = [NSMutableDictionary dictionaryWithCapacity:[[self winetricksList] count]];
		for (NSString *eachCategory in [self winetricksList])
		{
			NSDictionary *thisCategoryListOriginal = [[self winetricksList] valueForKey:eachCategory];
			NSMutableDictionary *thisCategoryList = [thisCategoryListOriginal mutableCopy];
			for (NSString *eachPackage in thisCategoryListOriginal) // Can't iterate on the copy being modified
			{
				if ([eachPackage rangeOfString:searchString options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch].location != NSNotFound) // Found in package name
					continue;
				if ([[[thisCategoryListOriginal valueForKey:eachPackage] valueForKey:@"WS-Description"] rangeOfString:searchString options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch].location != NSNotFound) // Found in package description
					continue;
				// Not found.  Remove the item from the dictionary
				[thisCategoryList removeObjectForKey:eachPackage];
			}
			if ([thisCategoryList count] > 0)
				[list setValue:thisCategoryList forKey:eachCategory];
		}
		[self setWinetricksFilteredList:list];
	}
	[winetricksOutlineView reloadData];
}
- (IBAction)winetricksCustomCommandToggled:(id)sender
{
	if ([sender state])
	{
		[winetricksCustomLine setEnabled:YES];
		[winetricksCustomLine setHidden:NO];
		[winetricksCustomLineLabel setHidden:NO];
		[winetricksOutlineView setEnabled:NO];
		[winetricksSearchField setEnabled:NO];
		[winetricksCustomLine becomeFirstResponder];
	}
	else
	{
		[winetricksCustomLine setEnabled:NO];
		[winetricksCustomLine setHidden:YES];
		[winetricksCustomLineLabel setHidden:YES];
		[winetricksOutlineView setEnabled:YES];
		[winetricksSearchField setEnabled:YES];
		[winetricksRunButton becomeFirstResponder];
	}
}
- (IBAction)winetricksToggleColumn:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL newState = !([sender state] == NSOnState);
	if (sender == winetricksShowInstalledColumn)
	{
		[sender setState:(newState ? NSOnState : NSOffState)];
		[defaults setBool:newState forKey:@"InstalledColumnShown"];
	}
	else if (sender == winetricksShowDownloadedColumn)
	{
		[sender setState:(newState ? NSOnState : NSOffState)];
		[defaults setBool:newState forKey:@"DownloadedColumnShown"];
	}
	[defaults synchronize];
	[self winetricksRefreshButtonPressed:self];
}
- (void)runWinetrick
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	winetricksDone = NO;
	// loop while winetricksDone is NO
	if ([winetricksCustomCheckbox state])
		[self systemCommand:[NSString stringWithFormat:@"%@/Contents/MacOS/Wineskin",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] withArgs:[[NSArray arrayWithObject:@"WSS-winetricks"] arrayByAddingObjectsFromArray:[[[winetricksCustomLine stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:@" "]]];
	else
		[self systemCommand:[NSString stringWithFormat:@"%@/Contents/MacOS/Wineskin",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] withArgs:[[NSArray arrayWithObject:@"WSS-winetricks"] arrayByAddingObjectsFromArray:[[self winetricksSelectedList] allKeys]]];
	winetricksDone = YES;
	// Remove installed and cached packages lists since they need to be rebuilt
	[[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/Contents/Resources/winetricksInstalled.plist",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/winetricks/winetricksCached.plist", [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]] error:nil];
	usleep(500000); // Wait just a little, to make sure logs aren't overwritten before updateWinetrickOutput is done
	[self winetricksRefreshButtonPressed:self];
	[self winetricksSelectNoneButtonPressed:self];
	[pool release];
	return;
}
- (void)doTheDangUpdate
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	// update text area with Winetricks log
	NSArray *winetricksOutput = [[NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Resources/Logs/Winetricks.log",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
	[winetricksOutputText setEditable:YES];
	[winetricksOutputText setString:@""];
	for (NSString *item in winetricksOutput)
		if (!([item hasPrefix:@"XIO:"]) && !([item hasPrefix:@"      after"]))
			[winetricksOutputText insertText:[NSString stringWithFormat:@"%@\n",item]];
	[winetricksOutputText setEditable:NO];
	[pool release];
}
- (void)winetricksWriteFinished
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[winetricksOutputText setEditable:YES];
	if (winetricksCanceled) [winetricksOutputText insertText:@"\n\n Winetricks CANCELED!!\nIt is possible that there are now problems with the wrapper, or other shell processes may have accidently been affected as well.  Usually its best to not cancel Winetricks, but in many cases it will not hurt.  You may need to refresh the wrapper, or in bad cases do a rebuild.\n\n"];
	[winetricksOutputText insertText:@"\n\n Winetricks Finished!!\n\n"];
	[winetricksOutputText setEditable:NO];
	[pool release];
}
- (void)updateWinetrickOutput
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	while (!winetricksDone)
	{
		//need the main thread to do the window update
		[self performSelectorOnMainThread:@selector(doTheDangUpdate) withObject:self waitUntilDone:YES]; 
		sleep(1);
	}
	// update text area with Winetricks log for last time, to make sure everything is there.
	[self performSelectorOnMainThread:@selector(doTheDangUpdate) withObject:self waitUntilDone:YES];
	// Write a finished statement since Winetricks doesn't seem to want to
	[self performSelectorOnMainThread:@selector(winetricksWriteFinished) withObject:self waitUntilDone:YES];
	//stop prog wheel
	[winetricksWaitWheel stopAnimation:self];
	//enable buttons back
	[winetricksRunButton setEnabled:YES];
	[winetricksUpdateButton setEnabled:YES];
	[winetricksRefreshButton setEnabled:YES];
	[winetricksDoneButton setEnabled:YES];
	//enable X button
	disableXButton = NO;
	//disable cancel button
	[winetricksCancelButton setHidden:YES];
	[winetricksCancelButton setEnabled:NO];
	[pool release];
}
- (NSArray *)makePIDArray:(NSString *)processToLookFor
{
	NSString *resultString = [NSString stringWithFormat:@"00000\n%@",[self systemCommandWithOutputReturned:[NSString stringWithFormat:@"ps axc|awk \"{if (\\$5==\\\"%@\\\") print \\$1}\"",processToLookFor]]];
	return [resultString componentsSeparatedByString:@"\n"];
}


//*********** CEXE
- (IBAction)createCustomExeLauncherButtonPressed:(id)sender
{
	[[NSFileManager defaultManager] removeItemAtPath:@"/tmp/Wineskin.icns" error:nil];
	[[NSFileManager defaultManager] copyItemAtPath:[NSString stringWithFormat:@"%@/Contents/Resources/Wineskin.icns",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] toPath:@"/tmp/Wineskin.icns" error:nil];
	NSImage *theImage = [[NSImage alloc] initByReferencingFile:@"/tmp/Wineskin.icns"];
	[cEXEIconImageView setImage:theImage];
	[theImage release];
	[cEXEWindow makeKeyAndOrderFront:self];
	[advancedWindow orderOut:self];
}
- (IBAction)cEXESaveButtonPressed:(id)sender
{
	//make sure name and exe fields are not blank
	//replace common symbols...
	[cEXENameToUseTextField setStringValue:[[cEXENameToUseTextField stringValue] stringByReplacingOccurrencesOfString:@"&" withString:@"and"]];
	[cEXENameToUseTextField setStringValue:[[cEXENameToUseTextField stringValue] stringByReplacingOccurrencesOfString:@"!" withString:@""]];
	[cEXENameToUseTextField setStringValue:[[cEXENameToUseTextField stringValue] stringByReplacingOccurrencesOfString:@"#" withString:@""]];
	[cEXENameToUseTextField setStringValue:[[cEXENameToUseTextField stringValue] stringByReplacingOccurrencesOfString:@"$" withString:@""]];
	[cEXENameToUseTextField setStringValue:[[cEXENameToUseTextField stringValue] stringByReplacingOccurrencesOfString:@"%" withString:@""]];
	[cEXENameToUseTextField setStringValue:[[cEXENameToUseTextField stringValue] stringByReplacingOccurrencesOfString:@"^" withString:@""]];
	[cEXENameToUseTextField setStringValue:[[cEXENameToUseTextField stringValue] stringByReplacingOccurrencesOfString:@"*" withString:@""]];
	[cEXENameToUseTextField setStringValue:[[cEXENameToUseTextField stringValue] stringByReplacingOccurrencesOfString:@"(" withString:@""]];
	[cEXENameToUseTextField setStringValue:[[cEXENameToUseTextField stringValue] stringByReplacingOccurrencesOfString:@")" withString:@""]];
	[cEXENameToUseTextField setStringValue:[[cEXENameToUseTextField stringValue] stringByReplacingOccurrencesOfString:@"+" withString:@""]];
	[cEXENameToUseTextField setStringValue:[[cEXENameToUseTextField stringValue] stringByReplacingOccurrencesOfString:@"=" withString:@""]];
	[cEXENameToUseTextField setStringValue:[[cEXENameToUseTextField stringValue] stringByReplacingOccurrencesOfString:@"|" withString:@""]];
	[cEXENameToUseTextField setStringValue:[[cEXENameToUseTextField stringValue] stringByReplacingOccurrencesOfString:@"\\" withString:@""]];
	[cEXENameToUseTextField setStringValue:[[cEXENameToUseTextField stringValue] stringByReplacingOccurrencesOfString:@"?" withString:@""]];
	[cEXENameToUseTextField setStringValue:[[cEXENameToUseTextField stringValue] stringByReplacingOccurrencesOfString:@">" withString:@""]];
	[cEXENameToUseTextField setStringValue:[[cEXENameToUseTextField stringValue] stringByReplacingOccurrencesOfString:@"<" withString:@""]];
	[cEXENameToUseTextField setStringValue:[[cEXENameToUseTextField stringValue] stringByReplacingOccurrencesOfString:@";" withString:@""]];
	[cEXENameToUseTextField setStringValue:[[cEXENameToUseTextField stringValue] stringByReplacingOccurrencesOfString:@":" withString:@""]];
	[cEXENameToUseTextField setStringValue:[[cEXENameToUseTextField stringValue] stringByReplacingOccurrencesOfString:@"@" withString:@""]];
	if ([[cEXENameToUseTextField stringValue] isEqualToString:@""])
	{
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Oops!"];
		[alert setInformativeText:@"You must type in a name to use!"];
		[alert setAlertStyle:NSInformationalAlertStyle];
		[alert runModal];
		[alert release];
		return;
	}
	else if ([[cEXEWindowsExeTextField stringValue] isEqualToString:@""])
	{
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Oops!"];
		[alert setInformativeText:@"You must choose an executable to run!"];
		[alert setAlertStyle:NSInformationalAlertStyle];
		[alert runModal];
		[alert release];
		return;
	}
	//make sure file doesn't exist, if it does, error and return
	if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@.app",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent],[cEXENameToUseTextField stringValue]]])
	{
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Oops! File already exists!"];
		[alert setInformativeText:@"That name is already in use, please choose a different name."];
		[alert setAlertStyle:NSInformationalAlertStyle];
		[alert runModal];
		[alert release];
		return;
	}
	
	//show busy window
	[busyWindow makeKeyAndOrderFront:self];
	//hide cEXE window
	[cEXEWindow orderOut:self];
	//copy cexe template over with correct name
	[[NSFileManager defaultManager] copyItemAtPath:[NSString stringWithFormat:@"%@/Contents/Resources/CustomEXE.app",[[NSBundle mainBundle] bundlePath]] toPath:[NSString stringWithFormat:@"%@/%@.app",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent],[cEXENameToUseTextField stringValue]] error:nil];
	//read cexe info.plist in
	NSString *TEST = [NSString stringWithFormat:@"%@/%@.app/Contents/Info.plist.cexe",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent],[cEXENameToUseTextField stringValue]];
	NSMutableDictionary *plistDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:TEST];
	//fix Program Name and Path line
	[plistDictionary setValue:[cEXEWindowsExeTextField stringValue] forKey:@"Program Name and Path"];
	//fix flags line
	[plistDictionary setValue:[cEXEFlagsTextField stringValue] forKey:@"Program Flags"];
	//fix start.exe entry
	if ([[cEXEUseStartExeCheckmark stringValue] isEqualToString:@"0"])
		[plistDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"use start.exe"];
	else
		[plistDictionary setValue:[NSNumber numberWithBool:YES] forKey:@"use start.exe"];
	//fix gamma entry
	if ([gammaSlider doubleValue] == 80.0)
		[plistDictionary setValue:@"default" forKey:@"Gamma Correction"];
	else
		[plistDictionary setValue:[NSString stringWithFormat:@"%1.2f",(100.0-([gammaSlider doubleValue]-80))/100] forKey:@"Gamma Correction"];
	if ([cEXEautoOrOvverrideDesktopToggleAutomaticButton intValue] == 1)
	{
		//set up for RandR
		[plistDictionary setValue:[NSNumber numberWithBool:YES] forKey:@"Use RandR"];
		[plistDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"Fullscreen"];
		[plistDictionary setValue:@"novdx24sleep0" forKey:@"Resolution"];
	}
	else
	{
		//fix randr entry
		[plistDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"Use RandR"];
		if ([cEXEFullscreenRootlessToggleRootlessButton intValue] == 1)
		{
			//set up for rootless
			[plistDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"Fullscreen"];
			//fix Fullscreen Entry
			if ([cEXENormalWindowsVirtualDesktopToggleNormalWindowsButton intValue] == 1)
				//fix Resolution entry for normal windows
				[plistDictionary setValue:@"novdx24sleep0" forKey:@"Resolution"];
			else
				//fix Resolution entry for virtual desktop
				[plistDictionary setValue:[NSString stringWithFormat:@"%@x24sleep0",[[cEXEVirtualDesktopResolution selectedItem] title]] forKey:@"Resolution"];
		}
		else
		{
			//set up for Fullscreen
			//fix Fullscreen Entry
			[plistDictionary setValue:[NSNumber numberWithBool:YES] forKey:@"Fullscreen"];
			//fix Resolution entry
			[plistDictionary setValue:[NSString stringWithFormat:@"%@x%@sleep%@",[[cEXEFullscreenResolution selectedItem] title],[[[cEXEColorDepth selectedItem] title] stringByReplacingOccurrencesOfString:@" bit" withString:@""],[[[cEXESwitchPause selectedItem] title] stringByReplacingOccurrencesOfString:@" sec." withString:@""]] forKey:@"Resolution"];
		}
	}
	//write out new cexe info.plist
	[plistDictionary writeToFile:[NSString stringWithFormat:@"%@/%@.app/Contents/Info.plist.cexe",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent],[cEXENameToUseTextField stringValue]] atomically:YES];
	[plistDictionary release];
	//move /tmp/Wineskin.icns into the cexe
	[[NSFileManager defaultManager] moveItemAtPath:@"/tmp/Wineskin.icns" toPath:[NSString stringWithFormat:@"%@/%@.app/Contents/Resources/Wineskin.icns",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent],[cEXENameToUseTextField stringValue]] error:nil];
	//give done message
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:@"Done!"];
	[alert setInformativeText:@"The Custom Exe Launcher has been made and can be found just inside the wrapper along with Wineskin.app.\n\nIf you want to be able to access it from outside of the app, just make and use an alias to it."];
	[alert setAlertStyle:NSInformationalAlertStyle];
	[alert runModal];
	[alert release];
	//show advanced window
	[advancedWindow makeKeyAndOrderFront:self];
	//hide busy window
	[busyWindow orderOut:self];
}
- (IBAction)cEXECancelButtonPressed:(id)sender
{
	[advancedWindow makeKeyAndOrderFront:self];
	[cEXEWindow orderOut:self];
}
- (IBAction)cEXEBrowseButtonPressed:(id)sender
{
	//NSOpenPanel *panel = [NSOpenPanel openPanel];
	NSOpenPanel *panel = [[NSOpenPanel alloc] init];
	[panel setTitle:@"Please choose the .exe, .msi, or .bat file that should run"];
	[panel setPrompt:@"Choose"];
	[panel setCanChooseDirectories:NO];
	[panel setCanChooseFiles:YES];
	[panel setAllowsMultipleSelection:NO];
	[panel setExtensionHidden:NO];
	[panel setTreatsFilePackagesAsDirectories:YES];
	//loop until choice is in drive_c
	BOOL inDriveC = NO;
	while (!inDriveC)
	{
		//open browse window to get .exe choice
		int error = [panel runModalForDirectory:[NSString stringWithFormat:@"%@/Contents/Resources/drive_c",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] file:nil types:[NSArray arrayWithObjects:@"exe",@"msi",@"bat",nil]];
		//exit loop if cancel pushed
		if (error == 0) break;
		if ([[[panel filenames] objectAtIndex:0] hasPrefix:[NSString stringWithFormat:@"%@/Contents/Resources/drive_c",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]]])
			inDriveC = YES;
	}
	//if cancel, return
	if (!inDriveC)
	{
		[panel release];
		return;
	}
	
	//write the result in windowsExeTextField, remove up through drive_c folder.
	[cEXEWindowsExeTextField setStringValue:[[[panel filenames] objectAtIndex:0] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/Contents/Resources/drive_c",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] withString:@""]];
	
	//if it is a .bat or a .msi, check the Use Start Exe Option
	if ([[cEXEWindowsExeTextField stringValue] hasSuffix:@".bat"] || [[cEXEWindowsExeTextField stringValue] hasSuffix:@".msi"])
		[cEXEUseStartExeCheckmark setState:1];
	[panel release];
}
- (IBAction)cEXEIconBrowseButtonPressed:(id)sender
{
	//NSOpenPanel *panel = [NSOpenPanel openPanel];
	NSOpenPanel *panel = [[NSOpenPanel alloc] init];
	[panel setTitle:@"Please choose the .icns file to use in the wrapper"];
	[panel setPrompt:@"Choose"];
	[panel setCanChooseDirectories:NO];
	[panel setCanChooseFiles:YES];
	[panel setAllowsMultipleSelection:NO];
	[panel setExtensionHidden:NO];
	[panel setTreatsFilePackagesAsDirectories:YES];
	//open browse to get .icns choice
	int error = [panel runModalForDirectory:@"/" file:nil types:[NSArray arrayWithObjects:@"icns",nil]];
	//if cancel return
	if (error == 0)
	{
		[panel release];
		return;
	}
	// delete old Wineskin.icns
	[[NSFileManager defaultManager] removeItemAtPath:@"/tmp/Wineskin.icns" error:nil];
	// copy [[panel filenames] objectAtIndex:0]] to be Wineskin.icns in tmp folder.  Save will use the one in tmp
	[[NSFileManager defaultManager] copyItemAtPath:[[panel filenames] objectAtIndex:0] toPath:@"/tmp/Wineskin.icns" error:nil];
	//refresh icon showing in config tab
	NSImage *theImage = [[NSImage alloc] initByReferencingFile:@"/tmp/Wineskin.icns"];
	[cEXEIconImageView setImage:theImage];
	[theImage release];
	[panel release];
}
- (IBAction)cEXEAutomaticButtonPressed:(id)sender
{
	[cEXEFullscreenRootlessToggle setEnabled:NO];
	[cEXENormalWindowsVirtualDesktopToggle setEnabled:NO];
	[cEXEVirtualDesktopResolution setEnabled:NO];
	[cEXEFullscreenResolution setEnabled:NO];
	[cEXEColorDepth setEnabled:NO];
	[cEXESwitchPause setEnabled:NO];
}
- (IBAction)cEXEOverrideButtonPressed:(id)sender
{
	[cEXEFullscreenRootlessToggle setEnabled:YES];
	[cEXENormalWindowsVirtualDesktopToggle setEnabled:YES];
	[cEXEVirtualDesktopResolution setEnabled:YES];
	[cEXEFullscreenResolution setEnabled:YES];
	[cEXEColorDepth setEnabled:YES];
	[cEXESwitchPause setEnabled:YES];
}
- (IBAction)cEXERootlessButtonPressed:(id)sender
{
	[cEXEFullscreenRootlesToggleTabView selectFirstTabViewItem:self];
}
- (IBAction)cEXEFullscreenButtonPressed:(id)sender
{
	[cEXEFullscreenRootlesToggleTabView selectLastTabViewItem:self];
}
- (IBAction)cEXEGammaChanged:(id)sender
{
	if ([cEXEGammaSlider doubleValue] != 80.0)
		[self systemCommand:[NSString stringWithFormat:@"%@/Contents/Resources/WSGamma",[[NSBundle mainBundle] bundlePath]] withArgs:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%1.2f",(100.0-([cEXEGammaSlider doubleValue]-80))/100],nil]];
}
- (IBAction)changeEngineUsedButtonPressed:(id)sender
{
	//get installed engines
	NSMutableArray *installedEnginesList = [NSMutableArray arrayWithCapacity:10];
	NSString *folder = [NSString stringWithFormat:@"%@/Library/Application Support/Wineskin/Engines",NSHomeDirectory()];
	NSArray *filesTEMP = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folder error:nil];
	NSArray *files = [[filesTEMP reverseObjectEnumerator] allObjects];
	for(NSString *file in files) // standard first
		if ([file hasSuffix:@".tar.7z"] && (NSEqualRanges([file rangeOfString:@"CX"],NSMakeRange(NSNotFound, 0)))) [installedEnginesList addObject:[file stringByReplacingOccurrencesOfString:@".tar.7z" withString:@""]];
	for(NSString *file in files) // CX at end of list
		if ([file hasSuffix:@".tar.7z"] && !(NSEqualRanges([file rangeOfString:@"CX"],NSMakeRange(NSNotFound, 0)))) [installedEnginesList addObject:[file stringByReplacingOccurrencesOfString:@".tar.7z" withString:@""]];
	//update engine list in change engine window
	[changeEngineWindowPopUpButton removeAllItems];
	for (NSString *item in installedEnginesList)
		[changeEngineWindowPopUpButton addItemWithTitle:item];
	//disable/enable OK button depending if any engines in the list
	if ([installedEnginesList count] == 0)
		[engineWindowOkButton setEnabled:NO];
	else
		[engineWindowOkButton setEnabled:YES];
	//** Show current installed engine version
	// read in current engine name from first line of version file in wswine.bundle
	if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/Contents/Frameworks/wswine.bundle/version",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]]])
	{
		NSString *currentEngineVersion = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Frameworks/wswine.bundle/version",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] encoding:NSUTF8StringEncoding error:nil];
		NSArray *currentEngineVersionArray = [currentEngineVersion componentsSeparatedByString:@"\n"];
		//change currentVersionTextField to engine name
		[currentVersionTextField setStringValue:[currentEngineVersionArray objectAtIndex:0]];
	}
	//show Change Engine Window
	[changeEngineWindow makeKeyAndOrderFront:self];
	//order out advanced window
	[advancedWindow orderOut:self];
}
- (IBAction)changeEngineUsedOkButtonPressed:(id)sender
{
	NSFileManager *fm = [NSFileManager defaultManager];
	//make sure 7za exists,if not prompt error and exit...
	if (!([fm fileExistsAtPath:[NSString stringWithFormat:@"%@/Library/Application Support/Wineskin/7za",NSHomeDirectory()]]))
	{
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"ERROR!"];
		[alert setInformativeText:@"Cannot continue... files missing.  Please try reinstalling an engine manually, or running Wineskin Winery.  Either should attempt to fix the problem."];
		[alert setAlertStyle:NSInformationalAlertStyle];
		[alert runModal];
		[alert release];
		//order in advanced window
		[advancedWindow makeKeyAndOrderFront:self];
		//order out change engine window
		[changeEngineWindow orderOut:self];
		return;
	}
	//show busy window
	[busyWindow makeKeyAndOrderFront:self];
	//hide change engine window
	[changeEngineWindow orderOut:self];
	//uncompress engine
	system([[NSString stringWithFormat:@"\"%@/Library/Application Support/Wineskin/7za\" x \"%@/Library/Application Support/Wineskin/Engines/%@.tar.7z\" \"-o/%@/Library/Application Support/Wineskin/Engines\"", NSHomeDirectory(),NSHomeDirectory(),[[changeEngineWindowPopUpButton selectedItem] title],NSHomeDirectory()] UTF8String]);
	system([[NSString stringWithFormat:@"/usr/bin/tar -C \"%@/Library/Application Support/Wineskin/Engines\" -xf \"%@/Library/Application Support/Wineskin/Engines/%@.tar\"",NSHomeDirectory(),NSHomeDirectory(),[[changeEngineWindowPopUpButton selectedItem] title]] UTF8String]);
	//remove tar
	[fm removeItemAtPath:[NSString stringWithFormat:@"%@/Library/Application Support/Wineskin/Engines/%@.tar",NSHomeDirectory(),[[changeEngineWindowPopUpButton selectedItem] title]] error:nil];
	//delete old engine
	[fm removeItemAtPath:[NSString stringWithFormat:@"%@/Contents/Frameworks/wswine.bundle",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] error:nil];
	//put engine in wrapper
	[fm moveItemAtPath:[NSString stringWithFormat:@"%@/Library/Application Support/Wineskin/Engines/wswine.bundle",NSHomeDirectory()] toPath:[NSString stringWithFormat:@"%@/Contents/Frameworks/wswine.bundle",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] error:nil];
	[self installEngine];
	//refresh wrapper
	[self systemCommand:[NSString stringWithFormat:@"%@/Contents/MacOS/Wineskin",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] withArgs:[NSArray arrayWithObjects:@"WSS-wineboot",nil]];
	[self loadAllData];
	//order in advanced window
	[advancedWindow makeKeyAndOrderFront:self];
	//hide busy window
	[busyWindow orderOut:self];
	[fm release];
}
- (IBAction)changeEngineUsedCancelButtonPressed:(id)sender
{
	//order in advanced window
	[advancedWindow makeKeyAndOrderFront:self];
	//order out change engine window
	[changeEngineWindow orderOut:self];
}
- (IBAction)updateWrapperButtonPressed:(id)sender
{
	NSFileManager *fm = [NSFileManager defaultManager];
	//get current version from Info.plist, change spaces to - to it matches master wrapper naming
	NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Info.plist",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]]];
	NSString *currentWrapperVersion = [plistDictionary valueForKey:@"CFBundleVersion"];
	currentWrapperVersion = [currentWrapperVersion stringByReplacingOccurrencesOfString:@" " withString:@"-"];
	currentWrapperVersion = [NSString stringWithFormat:@"%@.app",currentWrapperVersion];
	//get new master wrapper name
	NSArray *filesTEMP = [fm contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/Library/Application Support/Wineskin/Wrapper",NSHomeDirectory()] error:nil];
	NSMutableArray *files = [NSMutableArray arrayWithCapacity:2];
	for(NSString *file in filesTEMP)
	{
		if (!([file isEqualToString:@".DS_Store"])) [files addObject:file];
	}
	if ([files count] != 1)
	{
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Oops!"];
		[alert setInformativeText:@"There is an error with the installation of your Master Wrapper.  Please update your Wrapper in Wineskin Winery (a manual install of a wrapper for Wineskin Winery will work too)"];
		[alert setAlertStyle:NSInformationalAlertStyle];
		[alert runModal];
		[alert release];
		[plistDictionary release];
		return;
	}
	
	NSString *masterWrapperName = [files objectAtIndex:0];
	//if master wrapper and current wrapper have same versions, prompt its already updated and return
	if ([currentWrapperVersion isEqualToString:masterWrapperName])
	{
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"Do Not Update"];
		[alert addButtonWithTitle:@"Update"];
		[alert setMessageText:@"No update needed"];
		[alert setInformativeText:@"Your wrapper version matches the master wrapper version... no update needed.  Do you want to force and update?"];
		[alert setAlertStyle:NSInformationalAlertStyle];
		if ([alert runModal] != NSAlertSecondButtonReturn)
		{
			[alert release];
			[plistDictionary release];
			return;
		}
	}
	//confirm wrapper change
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"OK"];
	[alert addButtonWithTitle:@"Cancel"];
	[alert setMessageText:@"Please confirm..."];
	[alert setInformativeText:@"Are you sure you want to do this update?  It will change out the wrappers main Wineskin files with newer copies from whatever Master Wrapper you have installed with Wineskin Winery.  The following files/folders will be replaced in the wrapper:\nWineskin.app\nContents/MacOS\nContents/Frameworks\nContents/Resources/WineskinLauncher.nib\nContents/Resources/English.lproj/main.nib"];
	[alert setAlertStyle:NSInformationalAlertStyle];
	if ([alert runModal] == NSAlertSecondButtonReturn)
	{
		[alert release];
		[plistDictionary release];
		return;
	}
	[alert release];
	//show busy window
	[busyWindow makeKeyAndOrderFront:self];
	//hide advanced window
	[advancedWindow orderOut:self];
	//delete old MacOS, and copy in new
	[fm removeItemAtPath:[NSString stringWithFormat:@"%@/Contents/MacOS",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] error:nil];
	[fm copyItemAtPath:[NSString stringWithFormat:@"%@/Library/Application Support/Wineskin/Wrapper/%@/Contents/MacOS",NSHomeDirectory(),masterWrapperName] toPath:[NSString stringWithFormat:@"%@/Contents/MacOS",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] error:nil];
	//delete old WineskinLauncher.nib, and copy in new
	[fm removeItemAtPath:[NSString stringWithFormat:@"%@/Contents/Resources/WineskinLauncher.nib",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] error:nil];
	[fm copyItemAtPath:[NSString stringWithFormat:@"%@/Library/Application Support/Wineskin/Wrapper/%@/Contents/Resources/WineskinLauncher.nib",NSHomeDirectory(),masterWrapperName] toPath:[NSString stringWithFormat:@"%@/Contents/Resources/WineskinLauncher.nib",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] error:nil];
	//edit Info.plist to new wrapper version, replace - with spaces, and dump .app
	[plistDictionary setValue:[[masterWrapperName stringByReplacingOccurrencesOfString:@".app" withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@" "] forKey:@"CFBundleVersion"];
	//Make sure new keys are added to the old Info.plist
	NSMutableDictionary *newPlistDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Library/Application Support/Wineskin/Wrapper/%@/Contents/Info.plist",NSHomeDirectory(),masterWrapperName]]; 
	[newPlistDictionary addEntriesFromDictionary:plistDictionary];	
	[newPlistDictionary writeToFile:[NSString stringWithFormat:@"%@/Contents/Info.plist",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] atomically:YES];
	[newPlistDictionary release];
	[plistDictionary release];
	//force delete Wineskin.app and copy in new
	[fm removeItemAtPath:[NSString stringWithFormat:@"%@/Wineskin.app",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] error:nil];
	[fm copyItemAtPath:[NSString stringWithFormat:@"%@/Library/Application Support/Wineskin/Wrapper/%@/Wineskin.app",NSHomeDirectory(),masterWrapperName] toPath:[NSString stringWithFormat:@"%@/Wineskin.app",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] error:nil];
	//move wswine.bundle out of Frameworks
	[fm moveItemAtPath:[NSString stringWithFormat:@"%@/Contents/Frameworks/wswine.bundle",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] toPath:@"/tmp/wswineWSTEMP.bundle" error:nil];
	//replace Frameworks
	[fm removeItemAtPath:[NSString stringWithFormat:@"%@/Contents/Frameworks",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] error:nil];
	[fm copyItemAtPath:[NSString stringWithFormat:@"%@/Library/Application Support/Wineskin/Wrapper/%@/Contents/Frameworks",NSHomeDirectory(),masterWrapperName] toPath:[NSString stringWithFormat:@"%@/Contents/Frameworks",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] error:nil];
	//move wswine.bundle back into Frameworks
	[fm moveItemAtPath:@"/tmp/wswineWSTEMP.bundle" toPath:[NSString stringWithFormat:@"%@/Contents/Frameworks/wswine.bundle",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] error:nil];
	//change out main.nib
	[fm removeItemAtPath:[NSString stringWithFormat:@"%@/Contents/Resources/English.lproj/main.nib",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] error:nil];
	[fm copyItemAtPath:[NSString stringWithFormat:@"%@/Library/Application Support/Wineskin/Wrapper/%@/Contents/Resources/English.lproj/main.nib",NSHomeDirectory(),masterWrapperName] toPath:[NSString stringWithFormat:@"%@/Contents/Resources/English.lproj/main.nib",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] error:nil];
	//open new Wineskin.app
	[self systemCommand:@"/usr/bin/open" withArgs:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@/Wineskin.app",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]],nil]];
	//close program
	[fm release];
	[NSApp terminate:sender];
}
- (IBAction)logsButtonPressed:(id)sender
{
	[self systemCommand:@"/usr/bin/open" withArgs:[NSArray arrayWithObjects:@"-e",[NSString stringWithFormat:@"%@/Contents/Resources/Logs/LastRunX11.log",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]],nil]];
	[self systemCommand:@"/usr/bin/open" withArgs:[NSArray arrayWithObjects:@"-e",[NSString stringWithFormat:@"%@/Contents/Resources/Logs/LastRunWine.log",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]],nil]];
}
- (IBAction)commandLineShellButtonPressed:(id)sender
{
	[NSThread detachNewThreadSelector:@selector(runCmd) toTarget:self withObject:nil];
}
- (void)runCmd
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self disableButtons];
	[self systemCommand:[NSString stringWithFormat:@"%@/Contents/MacOS/Wineskin",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] withArgs:[NSArray arrayWithObjects:@"WSS-cmd",nil]];
	[self enableButtons];
	[pool release];
}
//*************************************************************
//*********************** OVERRIDES ***************************
//*************************************************************
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}
- (BOOL)windowShouldClose:(id)sender
{
	if (disableXButton)
	{
		return NO;
	}
	else if (sender==window)
	{
		//don't do anything... yet
	}
	else if (sender==advancedWindow)
	{
		[self saveAllData];
		[window makeKeyAndOrderFront:self];
	}
	else if (sender==screenOptionsWindow)
	{
		[self saveScreenOptionsData];
		[window makeKeyAndOrderFront:self];
	}
	else if (sender==winetricksWindow)
	{
		[self winetricksDoneButtonPressed:sender];
		return NO;
	}
	[sender orderOut:self];
	return NO;
}
- (NSApplicationTerminateReply)applicationShouldTerminate:(id)sender
{
	[self saveAllData];
	[self saveScreenOptionsData];
	return YES;
}
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	[self saveAllData];
}
//*************************************************************
//******************* Extensions Window ***********************
//*************************************************************
- (IBAction)extSaveButtonPressed:(id)sender
{
	if ([[extExtensionTextField stringValue] isEqualToString:@""] || [[extCommandTextField stringValue] isEqualToString:@""])
	{
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"Oops!"];
		[alert setMessageText:@"Error"];
		[alert setInformativeText:@"You left an entry field blank..."];
		[alert setAlertStyle:NSInformationalAlertStyle];
		[alert runModal];
		[alert release];
		return;
	}
	[busyWindow makeKeyAndOrderFront:self];
	[extAddEditWindow orderOut:self];
	//edit the system.reg to make sure Associations exist correctly, and add them if they do not.
	//make sure [extExtensionTextField stringValue] doesn't have dots
	[extExtensionTextField setStringValue:[[extExtensionTextField stringValue] stringByReplacingOccurrencesOfString:@"." withString:@""]];
	NSArray *arrayToSearch = [[NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Resources/system.reg",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
	NSMutableArray *finalArray =  [NSMutableArray arrayWithCapacity:[arrayToSearch count]];
	NSString *stringToWrite = [extCommandTextField stringValue];
	//fix stringToWrite to escape quotes and backslashes before writing
	stringToWrite = [stringToWrite stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
	stringToWrite = [stringToWrite stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
	BOOL matchMaker1 = NO;
	BOOL matchMaker2 = NO;
	BOOL waitUntilNextKey = NO;
	for (NSString *item in arrayToSearch)
	{
		if ([item hasPrefix:[NSString stringWithFormat:@"[Software\\\\Classes\\\\.%@]",[extExtensionTextField stringValue]]])
		{
			matchMaker1 = YES;
			waitUntilNextKey = YES;
			[finalArray addObject:item];
			[finalArray addObject:[NSString stringWithFormat:@"@=\"%@file\"",[extExtensionTextField stringValue]]];
			[finalArray addObject:@""];
			continue;
		}
		else if ([item hasPrefix:[NSString stringWithFormat:@"[Software\\\\Classes\\\\%@file\\\\shell\\\\open\\\\command]",[extExtensionTextField stringValue]]])
		{
			matchMaker2 = YES;
			waitUntilNextKey = YES;
			[finalArray addObject:item];
			[finalArray addObject:[NSString stringWithFormat:@"@=\"%@\"",stringToWrite]];
			[finalArray addObject:@""];
			continue;
		}
		if (waitUntilNextKey && [item hasPrefix:@"["]) waitUntilNextKey = NO;
		if (!waitUntilNextKey) [finalArray addObject:item];
	}
	if (!matchMaker1)
	{
		//entry didn't exist, just add at end
		[finalArray addObject:[NSString stringWithFormat:@"[Software\\\\Classes\\\\.%@]",[extExtensionTextField stringValue]]];
		[finalArray addObject:[NSString stringWithFormat:@"@=\"%@file\"",[extExtensionTextField stringValue]]];
		[finalArray addObject:@""];
	}
	if (!matchMaker2)
	{
		//entry didn't exist, just add at end
		[finalArray addObject:[NSString stringWithFormat:@"[Software\\\\Classes\\\\%@file\\\\shell\\\\open\\\\command]",[extExtensionTextField stringValue]]];
		[finalArray addObject:[NSString stringWithFormat:@"@=\"%@\"",stringToWrite]];
		[finalArray addObject:@""];
	}
	//write file back out to .reg file
	[@"" writeToFile:[NSString stringWithFormat:@"%@/Contents/Resources/system.reg",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] atomically:NO encoding:NSUTF8StringEncoding error:nil];
	NSFileHandle *aFileHandle = [NSFileHandle fileHandleForWritingAtPath:[NSString stringWithFormat:@"%@/Contents/Resources/system.reg",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]]];
	for (NSString *item in finalArray)
	{
		[aFileHandle truncateFileAtOffset:[aFileHandle seekToEndOfFile]];
		[aFileHandle writeData:[[NSString stringWithFormat:@"%@\n",item] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	//add to Info.plist
	NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Info.plist",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]]];
	NSArray *temp = [[plistDictionary valueForKey:@"Associations"] componentsSeparatedByString:@" "];
	NSMutableArray *assArray = [NSMutableArray arrayWithCapacity:[temp count]];
	[assArray addObjectsFromArray:temp];
	[assArray removeObject:[extExtensionTextField stringValue]];
	NSString *newExtString = [extExtensionTextField stringValue];
	for (NSString* item in assArray)
		newExtString = [NSString stringWithFormat:@"%@ %@",newExtString,item];
	if ([newExtString hasSuffix:@" "])
	{
		newExtString = [newExtString stringByAppendingString:@"WineskinRemover99"];
		newExtString = [newExtString stringByReplacingOccurrencesOfString:@" WineskinRemover99" withString:@""];
	}
	[plistDictionary setValue:newExtString forKey:@"Associations"];
	[plistDictionary writeToFile:[NSString stringWithFormat:@"%@/Contents/Info.plist",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] atomically:YES];
	[plistDictionary release];
	[self loadAllData];
	[advancedWindow makeKeyAndOrderFront:self];
	[busyWindow orderOut:self];
}
- (IBAction)extCancelButtonPressed:(id)sender
{
	[self loadAllData];
	[advancedWindow makeKeyAndOrderFront:self];
	[extAddEditWindow orderOut:self];
}

//*************************************************************
//************** Modify Mappings window ***********************
//*************************************************************
- (IBAction)modifyMappingsSaveButtonPressed:(id)sender
{
	NSMutableDictionary* plistDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Info.plist",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]]];
	[plistDictionary setValue:[modifyMappingsMyDocumentsTextField stringValue] forKey:@"Symlink My Documents"];
	[plistDictionary setValue:[modifyMappingsDesktopTextField stringValue] forKey:@"Symlink Desktop"];
	[plistDictionary setValue:[modifyMappingsMyVideosTextField stringValue] forKey:@"Symlink My Videos"];
	[plistDictionary setValue:[modifyMappingsMyMusicTextField stringValue] forKey:@"Symlink My Music"];
	[plistDictionary setValue:[modifyMappingsMyPicturesTextField stringValue] forKey:@"Symlink My Pictures"];
	[plistDictionary writeToFile:[NSString stringWithFormat:@"%@/Contents/Info.plist",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] atomically:YES];
	[advancedWindow makeKeyAndOrderFront:self];
	[modifyMappingsWindow orderOut:self];
	[plistDictionary release];
}

- (IBAction)modifyMappingsCancelButtonPressed:(id)sender
{
	[advancedWindow makeKeyAndOrderFront:self];
	[modifyMappingsWindow orderOut:self];
}

- (IBAction)modifyMappingsResetButtonPressed:(id)sender
{
	[modifyMappingsMyDocumentsTextField setStringValue:@"$HOME/Documents"];
	[modifyMappingsDesktopTextField setStringValue:@"$HOME/Desktop"];
	[modifyMappingsMyVideosTextField setStringValue:@"$HOME/Movies"];
	[modifyMappingsMyMusicTextField setStringValue:@"$HOME/Music"];
	[modifyMappingsMyPicturesTextField setStringValue:@"$HOME/Pictures"];
}

- (IBAction)modifyMappingsMyDocumentsBrowseButtonPressed:(id)sender
{
	NSOpenPanel *panel = [[NSOpenPanel alloc] init];
	[panel setTitle:@"Please choose the Folder \"My Documents\" should map to"];
	[panel setPrompt:@"Choose"];
	[panel setCanChooseDirectories:YES];
	[panel setCanChooseFiles:NO];
	[panel setAllowsMultipleSelection:NO];
	[panel setTreatsFilePackagesAsDirectories:YES];
	[panel setShowsHiddenFiles:YES];
	if ([panel runModalForDirectory:@"/" file:nil types:nil] != 0)
		[modifyMappingsMyDocumentsTextField setStringValue:[[[panel filenames] objectAtIndex:0] stringByReplacingOccurrencesOfString:NSHomeDirectory() withString:@"$HOME"]];
	[panel release];
}

- (IBAction)modifyMappingsMyDesktopBrowseButtonPressed:(id)sender
{
	NSOpenPanel *panel = [[NSOpenPanel alloc] init];
	[panel setTitle:@"Please choose the Folder \"Desktop\" should map to"];
	[panel setPrompt:@"Choose"];
	[panel setCanChooseDirectories:YES];
	[panel setCanChooseFiles:NO];
	[panel setAllowsMultipleSelection:NO];
	[panel setTreatsFilePackagesAsDirectories:YES];
	[panel setShowsHiddenFiles:YES];
	if ([panel runModalForDirectory:@"/" file:nil types:nil] != 0)
		[modifyMappingsDesktopTextField setStringValue:[[[panel filenames] objectAtIndex:0] stringByReplacingOccurrencesOfString:NSHomeDirectory() withString:@"$HOME"]];
	[panel release];
}

- (IBAction)modifyMappingsMyVideosBrowseButtonPressed:(id)sender
{
	NSOpenPanel *panel = [[NSOpenPanel alloc] init];
	[panel setTitle:@"Please choose the Folder \"My Videos\" should map to"];
	[panel setPrompt:@"Choose"];
	[panel setCanChooseDirectories:YES];
	[panel setCanChooseFiles:NO];
	[panel setAllowsMultipleSelection:NO];
	[panel setTreatsFilePackagesAsDirectories:YES];
	[panel setShowsHiddenFiles:YES];
	if ([panel runModalForDirectory:@"/" file:nil types:nil] != 0)
		[modifyMappingsMyVideosTextField setStringValue:[[[panel filenames] objectAtIndex:0] stringByReplacingOccurrencesOfString:NSHomeDirectory() withString:@"$HOME"]];
	[panel release];
}

- (IBAction)modifyMappingsMyMusicBrowseButtonPressed:(id)sender
{
	NSOpenPanel *panel = [[NSOpenPanel alloc] init];
	[panel setTitle:@"Please choose the Folder \"My Music\" should map to"];
	[panel setPrompt:@"Choose"];
	[panel setCanChooseDirectories:YES];
	[panel setCanChooseFiles:NO];
	[panel setAllowsMultipleSelection:NO];
	[panel setTreatsFilePackagesAsDirectories:YES];
	[panel setShowsHiddenFiles:YES];
	if ([panel runModalForDirectory:@"/" file:nil types:nil] != 0)
		[modifyMappingsMyMusicTextField setStringValue:[[[panel filenames] objectAtIndex:0] stringByReplacingOccurrencesOfString:NSHomeDirectory() withString:@"$HOME"]];
	[panel release];
}

- (IBAction)modifyMappingsMyPicturesBrowseButtonPressed:(id)sender
{
	NSOpenPanel *panel = [[NSOpenPanel alloc] init];
	[panel setTitle:@"Please choose the Folder \"My Pictures\" should map to"];
	[panel setPrompt:@"Choose"];
	[panel setCanChooseDirectories:YES];
	[panel setCanChooseFiles:NO];
	[panel setAllowsMultipleSelection:NO];
	[panel setTreatsFilePackagesAsDirectories:YES];
	[panel setShowsHiddenFiles:YES];
	if ([panel runModalForDirectory:@"/" file:nil types:nil] != 0)
		[modifyMappingsMyPicturesTextField setStringValue:[[[panel filenames] objectAtIndex:0] stringByReplacingOccurrencesOfString:NSHomeDirectory() withString:@"$HOME"]];
	[panel release];
}

//*************************************************************
//**************************** ICE ****************************
//*************************************************************
- (void)installEngine
{
	NSString *theSystemCommand = [NSString stringWithFormat: @"\"%@/Contents/MacOS/Wineskin\" WSS-InstallICE", [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]];
	system([theSystemCommand UTF8String]);
}
//*************************************************************
//*************************** TESTS ***************************
//*************************************************************
- (void)ds:(NSString *)input
{
	if (input == nil) input=@"nil";
	NSAlert *TESTER = [[NSAlert alloc] init];
	[TESTER addButtonWithTitle:@"close"];
	[TESTER setMessageText:@"Contents of string"];
	[TESTER setInformativeText:input];
	[TESTER setAlertStyle:NSInformationalAlertStyle];
	[TESTER runModal];
	[TESTER release];
}
//*************************************************************
//***** NSOutlineViewDataSource (winetricks) ******************
//*************************************************************
/* Required methods */
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)childIndex ofItem:(id)item {
	if (outlineView != winetricksOutlineView)
		return nil;
	if (!item)
		item = winetricksFilteredList;
	NSUInteger count = ([item valueForKey:@"WS-Name"] == nil ? [item count] : 0); // Set count to zero if the item is a package
	if (count <= childIndex)
		return nil;
	return [item objectForKey:[[[item allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] objectAtIndex:childIndex]];
}
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
	if (outlineView != winetricksOutlineView)
		return NO;
	if ([item valueForKey:@"WS-Name"] != nil)
		return NO;
	return YES;
}
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
	if (outlineView != winetricksOutlineView)
		return 0;
	if ([item valueForKey:@"WS-Name"] != nil)
		return 0;
	return [(item ? item : [self winetricksFilteredList]) count];
}
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	if (outlineView != winetricksOutlineView)
		return nil;
	if ((tableColumn == winetricksTableColumnRun
	     || tableColumn == winetricksTableColumnInstalled
	     || tableColumn == winetricksTableColumnDownloaded)
	    && [item valueForKey:@"WS-Name"] == nil)
		return @"";

	if (tableColumn == winetricksTableColumnRun)
	{
		NSNumber *thisEntry = [[self winetricksSelectedList] valueForKey:[item valueForKey:@"WS-Name"]];
		if (thisEntry == nil)
			return [NSNumber numberWithBool:NO];
		return thisEntry;
	}
	else if (tableColumn == winetricksTableColumnInstalled)
	{
		for (NSString *eachEntry in [self winetricksInstalledList])
			if ([eachEntry isEqualToString:[item valueForKey:@"WS-Name"]])
				return @"\u2713"; // Check mark character
		return @"";
	}
	else if (tableColumn == winetricksTableColumnDownloaded)
	{
		for (NSString *eachEntry in [self winetricksCachedList])
			if ([eachEntry isEqualToString:[item valueForKey:@"WS-Name"]])
				return @"\u2713"; // Check mark character
		return @"";
	}
	else if (tableColumn == winetricksTableColumnName)
	{
		if ([item valueForKey:@"WS-Name"] != nil)
			return [item valueForKey:@"WS-Name"];
		NSDictionary *parentDict = [outlineView parentForItem:item];
		return [[(parentDict ? parentDict : [self winetricksFilteredList]) allKeysForObject:item] objectAtIndex:0];
	}
	else if (tableColumn == winetricksTableColumnDescription)
	{
		if ([item valueForKey:@"WS-Description"] != nil)
			return [item valueForKey:@"WS-Description"];
		return @"";
	}
	return nil;
}
/* Optional Methods */
- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	if (outlineView != winetricksOutlineView)
		return;
	if (tableColumn != winetricksTableColumnRun)
		return;
	if ([item valueForKey:@"WS-Name"] == nil)
		return;
	[[self winetricksSelectedList] setValue:object forKey:[item valueForKey:@"WS-Name"]];
}
/* Delegate */
- (NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	if (tableColumn == winetricksTableColumnRun && [item valueForKey:@"WS-Name"] == nil)
		return [NSTextFieldCell new];
	return [tableColumn dataCellForRow:[outlineView rowForItem:item]];
}
@end

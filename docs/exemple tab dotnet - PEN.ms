--Destroy the dialog if it is already open 
try(destroyDialog testR)catch()

--Create a rollout
rollout testR "Test" width:300
(
	--Add a dot net tab control
	dotNetControl tabs "system.windows.forms.tabControl" width:(testR.width-30) height:25 
	--Add a sub rollout.
	subRollout subRoll "Sub" width:(testR.width-30) height:80 offset:[0,-5]
	
	--Function to show all properties, methods and events for any dotNet object
	fn showProps obj=
	(
		clearListener()
		format "Properties:\n"
		showProperties obj
		format "\nMethods:\n"
		showMethods obj
		format "\nEvents:\n"
		showEvents obj
	)
	
	--Add rollouts to the subRollout based on which tab is currently selected. 
	fn addTabRollout index=
	(
		--Remove any existing rollouts first. 
 		for x in subRoll.rollouts do removeSubRollout subRoll x
		
		sub=case index of
		(
			default:
			(
				rollout sub01 "Sub 01"
				(
					button testBt "test Button"
					on testBt pressed do (messageBox "You pressed the button" title:"Alert!")
				)
			)
			1:
			(
				rollout sub01 "Sub 02"
				(
					button testBt "test Button"
					on testBt pressed do (messageBox "You pressed the button" title:"Alert!")
				)
			)
			2:
			(
				rollout sub01 "Sub 03"
				(
					button testBt "test Button"
					on testBt pressed do (messageBox "You pressed the button" title:"Alert!")
				)
			)
		)
		addSubRollout subRoll sub
	)
	
	--Tab initilization function.
	fn initTabs tab labels:#() =
	(
		--Clear any existing tabs incase we do an update of them at some point. 
		tab.tabPages.clear()
		--Set the size mode so that we can control their width. 
		tab.sizeMode=tab.sizeMode.fixed
		--Set the width of every tab.
		tab.itemSize=dotnetObject "System.Drawing.Size" ((tab.width/labels.count)-2) 25
		
		--Loop through all the labels that we pass to the function and add a tab by the same name. 
 		for x in labels do tab.tabPages.add x
	)
	
	--When the mouse button is released on a tab get the selected tab and pass it to our addTabRollout function. 
	on tabs MouseUp senderArg arg do
	(
-- 		showProps arg
		addTabRollout senderArg.SelectedIndex
	)
	
	--When the rollout opens initilize the tab control
	on testR open do
	(
-- 		showProps tabs
		
		initTabs tabs labels:#("Général", "Façades", "Toiture")
		addTabRollout 0
	)
)
--Create the dialog
createDialog testR
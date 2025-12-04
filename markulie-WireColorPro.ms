-- WireColor Pro
-- Author: markulie
-- Description: Advanced wireframe color management tool featuring intelligent randomization, instance synchronization, gradient application, and seamless material conversion for 3ds Max.
-- Version: 1.33
-- Created: December 30, 2014
-- Updated: December 4, 2025
-- Website: https://github.com/markulie
-- Download: https://github.com/markulie/WireColorPro
-- Installation: Drag and drop this file into 3ds Max viewport

(
	global WireColorProDialog
	try (destroyDialog WireColorProDialog) catch()
	
	gc()
	
	rollout WireColorProDialog "WireColor Pro v1.33"
	(
		-- Color Constants
		local PASTEL_SATURATION = 120
		local PASTEL_VALUE_MIN = 150
		local PASTEL_VALUE_MAX = 240
		local GRAY_MIN = 0.2
		local GRAY_MAX = 0.8
		local CLAY_MIN = 5
		local CLAY_MAX = 30
		
		-- WireColor Randomizer
		
		group "Object                   Color"
		(
			radiobuttons radObject labels:#("All Geometry", "All Shapes", "All Groups", "All Objects", "Selection") across:2
			radiobuttons radColor labels:#("Pastel", "Gray", "Toxic", "Clay", "Random")
			checkButton chkIsInstance "Instance" tooltip:"When enabled, it will maintain consistent colors across instances." height:30 align:#left across:2
			button btnRandom "Randomize" tooltip:"Press to assign to objects" width:90 height:30 align:#right
		)
		
		fn getRandomColor =
		(
			local randomColor = blue
			case radColor.state of
			(
				1: -- Pastel
				(
					randomColor.hue = random 0 255
					randomColor.saturation = PASTEL_SATURATION
					randomColor.value = random PASTEL_VALUE_MIN PASTEL_VALUE_MAX
				)
				2: -- Gray
				(
					randomColor = white * random GRAY_MIN GRAY_MAX
				)
				3: -- Toxic
				(
					randomColor.hue = random 0 255
					randomColor.saturation = 255
				)
				4: -- Clay
				(
					local r = random CLAY_MIN CLAY_MAX
					randomColor = color (r*6) (r*2) r
				)
				5: -- Random
				(
					randomColor = random black white
				)
			)
			return randomColor
		)
		
		fn applyColorToObjects objArray useInstances =
		(
			for i in objArray do
			(
				try
				(
					InstanceMgr.GetInstances i &instArray
					if useInstances then
					(
						instArray.wirecolor = getRandomColor()
					)
					else
					(
						i.wirecolor = getRandomColor()
					)
				)
				catch
				(
					format "Warning: Could not set color for object: %\n" i.name
				)
			)
		)
		
		on btnRandom pressed do
		(
			with undo on
			(
				try
				(
					case radObject.state of
					(
						1: -- All Geometry
						(
							applyColorToObjects geometry chkIsInstance.checked
						)
						2: -- All Shapes
						(
							applyColorToObjects shapes chkIsInstance.checked
						)
						3: -- All Groups
						(
							allGroups = for obj in objects where isGroupHead obj collect obj
							if allGroups.count == 0 then
							(
								messageBox "There are no groups in the scene."
							)
							else
							(
								if chkIsInstance.checked then
								(
									for group in allGroups do
									(
										local randomColor = getRandomColor()
										for i in group do
										(
											try
											(
												InstanceMgr.GetInstances i &instArray
												instArray.wirecolor = randomColor
											)
											catch()
										)
									)
								)
								else
								(
									for group in allGroups do
									(
										local randomColor = getRandomColor()
										for i in group do
										(
											try (i.wirecolor = randomColor) catch()
										)
									)
								)
							)
						)
						4: -- All Objects
						(
							applyColorToObjects objects chkIsInstance.checked
						)
						5: -- Selection
						(
							if selection.count < 1 then
							(
								messageBox "Please select at least one object"
							)
							else
							(
								applyColorToObjects selection chkIsInstance.checked
							)
						)
					)
					redrawviews()
				)
				catch
				(
					messageBox "An error occurred during randomization."
				)
			)
		)
		
		-- End
		
		-- Gradient WireColor
		
		group "Gradient"
		(
			colorpicker cpGradient1 color:[58, 122, 205] width:77 height:20 align:#left across:2
			colorpicker cpGradient2 color:[139, 49, 165] width:77 height:20 align:#right
		)
		
		fn FnGradient =
		(
			try
			(
				local domain = if selection.count == 0 then objects else selection
				local cnt = domain.count
				
				if cnt < 2 then
				(
					messageBox "Gradient requires at least 2 objects.\nPlease select multiple objects or ensure scene has 2+ objects."
				)
				else if cnt >= 2 then
				(
					local col1 = cpGradient1.color
					local col2 = cpGradient2.color
					local step = (col2 - col1) / (cnt - 1)
					for i = 1 to cnt do domain[i].wireColor = col1 + (i - 1) * step
					redrawviews()
				)
			)
			catch
			(
				messageBox "Error applying gradient."
			)
		)
		
		on cpGradient1 changed val do FnGradient()
		on cpGradient2 changed val do FnGradient()
		
		-- End
		
		-- Realtime WireColor
		
		group "Realtime"
		(
			colorpicker cp "" width:140 height:20 color:[119, 95, 192] align:#center
		)
		
		on cp changed newColor do
		(
			try
			(
				if selection.count > 0 then
				(
					for obj in selection do
					(
						obj.wirecolor = newColor
					)
				)
				else
				(
					for obj in objects do
					(
						obj.wirecolor = newColor
					)
				)
			)
			catch
			(
				messageBox "Error applying realtime color."
			)
		)
		
		-- End
		
		-- Convert WireColors to Materials
		
		group "Convert to Materials"
		(
			radiobuttons radMaterial labels:#("Standard", "Physical") across:2
			button btnConverter "Convert" tooltip:"Convert WireColor to Material" width:70 height:30 align:#right
		)
		
		fn FnMatS objs =
		(
			local successCount = 0
			for i in objs do
			(
				try
				(
					if superClassOf i == geometryClass then
					(
						newColor = i.wireColor
						i.material = standardMaterial showInViewport:true name:("WireColor Pro - " + i.name)
						i.material.diffuse = newColor
						successCount += 1
					)
				)
				catch
				(
					format "Warning: Could not convert material for object: %\n" i.name
				)
			)
			redrawviews()
			return successCount
		)
		
		fn FnMatP objs =
		(
			local successCount = 0
			for i in objs do
			(
				try
				(
					if superClassOf i == geometryClass then
					(
						newColor = i.wireColor
						i.material = physicalMaterial showInViewport:true name:("WireColor Pro - " + i.name)
						i.material.Base_Color = newColor
						successCount += 1
					)
				)
				catch
				(
					format "Warning: Could not convert material for object: %\n" i.name
				)
			)
			redrawviews()
			return successCount
		)
		
		on btnConverter pressed do
		(
			if selection.count < 1 then
			(
				messageBox "Please select at least one object"
			)
			else
			(
				try
				(
					local count = 0
					if radMaterial.state == 1 then
					(
						count = FnMatS selection
					)
					else if radMaterial.state == 2 then
					(
						count = FnMatP selection
					)
					
					if count > 0 then
					(
						messageBox (count as string + " material(s) created successfully!") title:"WireColor Pro"
					)
				)
				catch
				(
					messageBox "Error converting materials."
				)
			)
		)
		
		-- End
		
		-- Erase Materials
		
		group "Erase Materials"
		(
			radiobuttons radErase labels:#("Selection", "All") across:2
			Button btnErase "Erase" tooltip:"Remove materials from objects" width:70 height:30 align:#right
		)
		
		on btnErase pressed do
		(
			try
			(
				if radErase.state == 1 then
				(
					if selection.count < 1 then
					(
						messageBox "Please select at least one object"
					)
					else
					(
						local count = selection.count
						$.material = undefined
						messageBox (count as string + " material(s) erased successfully!") title:"WireColor Pro"
					)
				)
				else
				(
					if geometry.count < 1 then
					(
						messageBox "You have no geometry objects"
					)
					else
					(
						local count = geometry.count
						geometry.material = undefined
						messageBox (count as string + " material(s) erased successfully!") title:"WireColor Pro"
					)
				)
			)
			catch
			(
				messageBox "Error erasing materials."
			)
		)
		
		-- End
		
		hyperLink author "Made with ♥ for Lilit" address:"https://github.com/markulie/3dsmax-wirecolor-pro" color:(color 150 150 150) hovercolor:(color 255 255 255) visitedcolor:(color 150 150 150) align:#center
	)
	
	-- Rollout
	
	createDialog WireColorProDialog 180 365
	cui.RegisterDialogBar WireColorProDialog minSize:[180, 380] maxSize:[180, 360] style:#(#cui_floatable, #cui_dock_left, #cui_dock_right, #cui_handles)
)
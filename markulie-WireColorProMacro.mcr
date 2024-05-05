macroScript WireColorProMacro
category:"markulie"
buttonText:"WireColor Pro"
toolTip:"WireColor Pro | Advanced WireColor Tool"

-- WireColor Pro
-- Author: markulie
-- Description: Object color randomization, instance sync, gradients, and material control for 3ds Max.
-- Version: 1.24
-- Created: December 30, 2014
-- Updated: August 24, 2023
-- Website: https://github.com/markulie
-- Download: https://github.com/markulie/WireColorPro

(  
	global WireColorProDialog  
	try ( destroyDialog WireColorProDialog ) catch()   

	gc()   

	rollout WireColorProDialog "WireColor Pro v1.24"  
	(  
		-- WireColor Randomizer               

		group "Object                   Color"  
		(  
			radiobuttons radObject labels:#( "All Geometry", "All Shapes", "All Groups", "All Objects", "Selection" ) across:2  			  
			radiobuttons radColor labels:#( "Pastel", "Gray", "Toxic" , "Clay", "Random") 
			checkButton chkIsInstance "Instance" tooltip:"When enabled, it will maintain consistent colors across instances." height:  30 align:#left across:2  
			button btnRandom "Randomize" tooltip:"Press to assign to objects" width:  90 height:  30 align:#right  
		)  

		fn getRandomColor =  
		(  
			local randomColor = blue  
			if radColor.state == 1 then  
			(  
				randomColor.hue = random 0 255  
				randomColor.saturation = 120  
				randomColor.value = random 150 240  
			)  
			else if radColor.state == 2 then       
			(  
				randomColor = white * random 0.2 0.8  
			)  
			else if radColor.state == 3 then  
			(  
				randomColor.hue = random 0 255  
				randomColor.saturation = 255  
			)
			else if radColor.state == 4 then  
			(  	
				local r = random 5 30	
				randomColor = color (r*6) (r*2) r
			)  
			else if radColor.state == 5 then  
			(  
				randomColor = random black white  
			)  
			return randomColor  
		)  

		on btnRandom pressed do  
		(  
			with undo on
			(	
				if radObject.state == 1 then  
				(  
					for i in geometry do  
					(  
						InstanceMgr.GetInstances i &instArray  
						if chkIsInstance.checked then  
						(  
							instArray.wirecolor = getRandomColor()   
						)  
						else  
						(  
							i.wirecolor = getRandomColor()   
						)  
					)  
				) 
				else if radObject.state == 2 then  
				(  
					for i in shapes do  
					(  
						InstanceMgr.GetInstances i &instArray  
						if chkIsInstance.checked then  
						(  
							instArray.wirecolor = getRandomColor()   
						)  
						else  
						(  
							i.wirecolor = getRandomColor()   
						)  
					)  
				)
				else if radObject.state == 3 then  
				(  
					allGroups = for obj in objects where isGroupHead obj collect obj  
					if allGroups.count == 0 then  
					(  
						messageBox "There are no groups in the scene."  
					)  
					else  
					(  
						fn changeInstancesRandom group =  
						(  
							local randomColor = getRandomColor()   
							for i in group do  
							(  
								InstanceMgr.GetInstances i &instArray  
								instArray.wirecolor = randomColor	
							)
						) 
						fn changeWireColorRandom group =  
						(  
							local randomColor = getRandomColor()   
							for i in group do  
							(
								i.wirecolor = randomColor  
							)
						)
						
						if chkIsInstance.checked then
						(
							for group in allGroups do  
							(  
								changeInstancesRandom group  
							)
						)
						for group in allGroups do  
						(  
							changeWireColorRandom group  
						)						
					)  
				) 
				else if radObject.state == 4 then  
				(  
					for i in objects do  
					(  
						InstanceMgr.GetInstances i &instArray  
						if chkIsInstance.checked then  
						(  
							instArray.wirecolor = getRandomColor()   
						)  
						else  
						(  
							i.wirecolor = getRandomColor()   
						)  
					)  
				)  				
				else if radObject.state == 5 then  
				(  
					if selection.count < 1 then messagebox "Please select at least one object"  
					else  
					(  
						for i in selection do  
						(  
							InstanceMgr.GetInstances i &instArray  
							if chkIsInstance.checked then  
							(  
								instArray.wirecolor = getRandomColor()   
							)  
							else  
							(  
								i.wirecolor = getRandomColor()   
							)  
						)  
					)  
				) 
			)
			redrawviews()   
		)  
		 
		-- End               
		 
		-- Gradient WireColor               
		 
		group "Gradient"  
		(  
			colorpicker cpGradient1 color:  [58, 122, 205] width:77 height:20 align:#left across:2  
			colorpicker cpGradient2 color:  [139, 49, 165] width:77 height:20 align:#right  
		)  
		 
		fn FnGradient =  
		(  
			local domain = if selection.count == 0 then objects else selection  
			local cnt = domain.count  
			if cnt >= 2 then  
			(  
				local col1 = cpGradient1.color  
				local col2 = cpGradient2.color  
				local step = ( col2 - col1 ) / ( cnt - 1 )  
				for i = 1 to cnt do domain[i].wireColor = col1 + ( i - 1 ) * step  
			)  
			redrawviews()   
		)  

		on cpGradient1 changed val do FnGradient()   
		on cpGradient2 changed val do FnGradient()   

		-- End               

		-- Realtime WireColor               

		group "Realtime"  
		(  
			colorpicker cp "" width:140 height:20 color:  [119, 95, 192] align:#center  
		)  

		on cp changed newColor do  
		(  
			if selection.count > 0 then  
			(  
				for obj in selection do  
				(  
					selection.wirecolor = newColor  
				)  
			)  
			else  
			(  
				for obj in geometry do  
				(  
					geometry.wirecolor = newColor  
				)  
			)  
		)  
		
		-- End               


		-- Convert WireColors to Materials               

		group "Convert to Materials"  
		(  
			radiobuttons radMaterial labels:#( "Standard", "Physical" ) across:2  
			button btnConverter "Convert" tooltip:"Convert WireColor to Material" width:70 height:30 align:#right  
		)  

		fn FnMatS objs =  
		(  
			for i in objs do  
			(  
				if superClassOf i == geometryClass then  
				(  
					newColor = i.wireColor  
					i.material = standardMaterial showInViewport:true name:  ( "WireColor Pro - " + i.name )  
					i.material.diffuse = newColor  
				)  
			)  
			redrawviews()   
		)  

		fn FnMatP objs =  
		(  
			for i in objs do  
			(  
				if superClassOf i == geometryClass then  
				(  
					newColor = i.wireColor  
					i.material = physicalMaterial showInViewport:true name:  ( "WireColor Pro - " + i.name )  
					i.material.Base_Color = newColor  
				)  
			)  
			redrawviews()   
		)  

		on btnConverter pressed do  
		(  
			if selection.count < 1 then  
			(  
				messagebox "Please select at least one object"  
			)  
			else  
			(  
				if radMaterial.state == 1 then  
				(  
					FnMatS selection  
				)  
				else if radMaterial.state == 2 then  
				(  
					FnMatP selection  
				)  
			)  
		)  

		-- End               


		-- Erase Materials               

		group "Erase Materials"  
		(  
			radiobuttons radErase labels:#( "Selection", "All" ) across:2  
			Button btnErase "Erase" tooltip:"Assign to objects" width:70 height:30 align:#right  
		)  

		on btnErase pressed do  
		(  
			if radErase.state == 1 then  
			(  
				if selection.count < 1 then  
				(  
					messagebox "Please select at least one object"  
				)  
				else  
				(  
					$.material = undefined  
				)  
			)  
			else  
			(  
				if geometry.count < 1 then  
				(  
					messagebox "You have no geometry objects"  
				)  
				else  
				(  
					geometry.material = undefined  
				)  
			)  
		)  

		-- End               

		hyperLink author "markulie" address:"https://markulie.github.io" color:( color 150 150 150) hovercolor:( color 255 255 255 ) visitedcolor:( color 150 150 150 ) align:#center  
	)  

	-- Rollout               

	createDialog WireColorProDialog 180 365  
	cui.RegisterDialogBar WireColorProDialog minSize:  [180, 380] maxSize:  [180, 360] style:#( #cui_floatable, #cui_dock_left, #cui_dock_right, #cui_handles )
)

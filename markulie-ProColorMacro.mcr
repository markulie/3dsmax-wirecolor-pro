macroscript ProColorMacro
    category:"markulie"
    buttonText:"ProColor"
    toolTip:"ProColor | Advanced WireColor Manager for 3ds Max"

-- ProColor
-- Author: Markulie
-- Description: Advanced WireColor Manager for 3ds Max
-- Version: 1.01
-- Created: December 30, 2014
-- Updated: October 21, 2022

(
global ProColorDialog
try (destroyDialog ProColorDialog)catch()

gc()
rollout ProColorDialog "ProColor v1.01"
(

    -- WireColor Randomizer

    group "WireColor Randomizer"
    (
        radiobuttons radColor labels:#("Random", "Pastel", "Gray") across:2
        radiobuttons radObject labels:#("Geometry", "Selection", "All Objects") across:2
        button btnRandom "Randomize" tooltip:"Assign to objects" width:80 height:30 align:#center
    )

    fn FnRandomizer objs =
    (
        if radColor.state == 1  then
            for i in objs do
            (i.wirecolor = random black white)

        else if radColor.state == 2  then
            for i in objs do
            (
                InstanceMgr.GetInstances i &instArray
                local newColor = blue
                newColor.hue = random 0 255
                newColor.saturation = 120
                newColor.value = random 150 240
                instArray.wirecolor = newColor
            )
        else if radColor.state == 3  then
            for i in objs do
            (i.wirecolor = white * random 0.2 0.8)

        redrawviews()
    )

    on btnRandom pressed do
    (
        if radObject.state == 1 then FnRandomizer geometry
        else if radObject.state == 2 then
        (
            if selection.count > 0 then FnRandomizer selection
            else messagebox "Please select at least one object"
        )
        else FnRandomizer objects
    )

    -- End


    -- Gradient WireColor
    
    group "Gradient WireColor"
    (
        colorpicker cpGradient1 color:[43,87,152] width:77 height:25 align:#left across:2
        colorpicker cpGradient2 color:[126,47,133] width:77 height:25 align:#right
    )
    
    fn FnGradient =
    (
        local domain = if selection.count == 0 then objects else selection
        local cnt = domain.count
        if cnt >= 2 then
        (
            local col1 = cpGradient1.color
            local col2 = cpGradient2.color
            local step = (col2 - col1) / (cnt - 1)
            for i = 1 to cnt do domain[i].wireColor = col1 + (i - 1) * step
        )
        redrawviews()
    )

    on cpGradient1 changed val do FnGradient()
    on cpGradient2 changed val do FnGradient()

    -- End

    
    -- Realtime WireColor

    group "Realtime WireColor"
    (
        colorpicker cp "" width:140 height:20 color:[38,130,118] align:#center
    )

    on cp changed newColor do
    (
        if selection.count > 0 then for obj in selection do selection.wirecolor = newColor
        else for obj in geometry do geometry.wirecolor = newColor
    )

    -- End


    -- Convert WireColors to Materials

    group "Convert WireColors to Materials"
    (
        radiobuttons radMaterial labels:#("Standard", "Physical") across:2
        button btnConverter "Convert" tooltip:"Convert WireColor to Material" width:70 height:30 align:#right
    )

    fn FnMatS objs =
    (
        for i in objs do
        (
            if superClassOf i == geometryClass then
            (
                newColor = i.wireColor
                i.material = standardMaterial showInViewport:true name: ("Converted w/ ProColor " + i.name)
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
                i.material = physicalMaterial showInViewport:true name: ("Converted w/ ProColor " + i.name)
                i.material.Base_Color = newColor
            )
        )
        redrawviews()
    )

    on btnConverter pressed do
    (
        if selection.count > 0 then
        (
            if radMaterial.state == 1 then FnMatS selection
            else if radMaterial.state == 2 then FnMatP selection
        )
        else messagebox "Please select at least one object"
    )

    -- End


    -- Erase Materials

    group "Erase Materials"
    (
        radiobuttons radErase labels:#("Selection", "All") across:2
        Button btnErase "Erase" tooltip:"Assign to objects" width:70 height:30 align:#right
    )

    on btnErase pressed do
    (
        if radErase.state == 1 then
        (
            if selection.count > 0 then $.material = undefined
            else messagebox "Please select at least one object"
        )
        else
        (
            if geometry.count > 0 then geometry.material = undefined
            else messagebox "You have no geometry objects"
        )
    )

    -- End

    hyperLink author "markulie" address:"https://markulie.github.io" color:(color 255 200 200) hovercolor:(color 255 0 0) visitedcolor:(color 255 255 255) align:#center
)
-- Rollout

createDialog ProColorDialog 180 360
cui.RegisterDialogBar ProColorDialog minSize:[180,360] maxSize:[180,360] style:#(#cui_floatable,#cui_dock_left,#cui_dock_right,#cui_handles)
)
-- Macro
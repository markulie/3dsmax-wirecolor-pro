-- ProColor
-- Description: Advanced WireColor Manager for 3ds Max
-- Version: 0.8
-- Author: Markulie
-- Created: December 30, 2014
-- Updated: September 29, 2020


macroscript ProColorMacro
    category:"markulie"
    buttonText:"ProColor"
    toolTip:"ProColor | Advanced WireColor Manager for 3ds Max"
(
global ProColorDialog
try (destroyDialog ProColorDialog)catch()

rollout ProColorDialog "ProColor v0.8"
(
    group "Random Colors"
    (
        radiobuttons RadRan labels:#("Geometry", "Selection", "All") across:2
        Button DoRan "Generate" tooltip:"Assign to objects" width:70 height:40 align:#right
    )

    function fn_Random objs = for i in objs do i.wirecolor = random black white

    on DoRan pressed do
    (
        if RadRan.state == 1 then fn_Random geometry
        else if RadRan.state == 2 then
        (
            if selection.count > 0 then fn_Random selection
            else messagebox "Please select at least one object"
        )
        else fn_Random objects
    )

    group "Random Gray Colors"
    (
        radiobuttons RanGray labels:#("Geometry", "Selection", "All") across:2
        button DoGray "Generate" tooltip:"Assign to objects" width:70 height:40 align:#right
    )

    function fn_Gray objs = for i in objs do i.wirecolor = white * random 0.2 0.8

    on DoGray pressed do
    (
        if RanGray.state == 1 then fn_Gray geometry
        else if RanGray.state == 2 then
        (
            if selection.count > 0 then	fn_Gray selection
            else messagebox "Please select at least one object"
        )
        else fn_Gray objects
    )
    
    group "Gradient"
    (
        colorpicker gcpl color:[32,64,122] width:77 height:25 align:#left across:2
        colorpicker gcpr color:[100,23,23] width:77 height:25 align:#right
    )
    
    fn apply_gradient = 
    (
        local domain = if selection.count == 0 then objects else selection
        local cnt = domain.count
        if cnt >= 2 then
        (
            local col1 = gcpl.color
            local col2 = gcpr.color
            local step = (col2 - col1) / (cnt - 1)
            for i = 1 to cnt do domain[i].wireColor = col1 + (i - 1) * step
        )
    )

    on gcpl changed val do apply_gradient()
    on gcpr changed val do apply_gradient()

    group "Real Time"
    (
        colorpicker rtcp "" width:152 height:20 color:[38,130,118]
    )

    on rtcp changed new_col do
    (
        if selection.count > 0 then for obj in selection do selection.wirecolor = new_col
        else for obj in geometry do geometry.wirecolor = new_col
    )

    group "WireColor to Materials"
    (
        radiobuttons RadMat labels:#("Standard", "Physical") across:2
        button convertBtn "Convert" tooltip:"Convert WireColor to Material" width:70 height:40 align:#right
    )

    function fn_MatS objs =
    (
        for i in objs do
        (
            if superClassOf i == geometryClass then
            (
                myColor = i.wireColor
                i.material = standardMaterial showInViewport:true name: ("converted_with_ProColor_"+i.name)
                i.material.diffuse = (myColor)
            )
        )
    )

    function fn_MatP objs =
    (
        for i in objs do
        (
            if superClassOf i == geometryClass then
            (
                myColor = i.wireColor
                i.material = physicalMaterial showInViewport:true name: ("converted_with_ProColor_"+i.name)
                i.material.Base_Color = (myColor)
            )
        )
    )

    on convertBtn pressed do
    (
        if selection.count > 0 then
        (
            if RadMat.state == 1 then fn_MatS selection
            else if RadMat.state == 2 then fn_MatP selection
        )
        else messagebox "Please select at least one object"
    )

    group "Erase Materials"
    (
        radiobuttons radErase labels:#("Selection", "All") across:2
        Button btnErase "Erase" tooltip:"Assign to objects" width:70 height:40 align:#right
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

    hyperLink author "markulie" address:"https://markulie.github.io" color:(color 255 255 255) hovercolor:(color 255 0 0) visitedcolor:(color 255 255 255) align:#center

)--rollout

createDialog ProColorDialog 180 416
cui.RegisterDialogBar ProColorDialog minSize:[180,416] maxSize:[180,416] style:#(#cui_floatable,#cui_dock_left,#cui_dock_right,#cui_handles)
)--macro
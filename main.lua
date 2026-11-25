
-- LSAI Application Entry Point
-- Version: 0.4.0
-- Runtime: LÖVE (Love2D)

local GUI
local Theme
local Components
local Pages
local Adapter

local initialized = false
local errorMessage = nil

function love.load()
    love.window.setTitle("LSAI v0.4.0")
    love.window.setMode(900, 600, {
        resizable = true,
        minwidth = 500,
        minheight = 400
    })

    love.graphics.setBackgroundColor(0.10, 0.11, 0.14)

    local success, result = pcall(function()
        GUI = require("gui.gui")
        Theme = require("gui.theme")
        Components = require("gui.components")
        Pages = require("gui.pages")
        Adapter = require("gui.adapter")

        local adapterOK, adapterError = Adapter.Initialize()

        if not adapterOK then
            error(adapterError)
        end

        local guiOK, guiError = GUI.Initialize({
            Theme = Theme,
            Components = Components,
            Pages = Pages,
            Adapter = Adapter
        })

        if not guiOK then
            error(guiError)
        end

        GUI.Open()
    end)

    if success then
        initialized = true
    else
        errorMessage = tostring(result)
    end
end

function love.update(dt)
    if initialized and Adapter then
        Adapter.Update(dt)
    end
end

function love.draw()
    if initialized and Adapter then
        Adapter.Draw()
        return
    end

    if errorMessage then
        love.graphics.setColor(1, 0.35, 0.35)
        love.graphics.printf(
            "LSAI startup error:\n" .. errorMessage,
            30, 30,
            love.graphics.getWidth() - 60
        )
    end
end

function love.keypressed(key)
    if not initialized then
        return
    end

    if key == "escape" then
        GUI.Toggle()
    end
end

function love.mousepressed(x, y, button)
    if not initialized or button ~= 1 then
        return
    end

    local width = Adapter.Width
    local height = Adapter.Height

    local panelX = love.graphics.getWidth() - width
    local panelY = (love.graphics.getHeight() - height) / 2

    if x >= panelX + width - 42
        and x <= panelX + width
        and y >= panelY
        and y <= panelY + 48 then

        GUI.Close()
    end
end

function love.quit()
    initialized = false
end

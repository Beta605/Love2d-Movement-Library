local movement = {
    _cellSize = 16
}

movement.GRID = "grid"
movement.TILED = "tiled"
movement.NORMAL = "normal"

function movement.cellSize(size)
    movement._cellSize = size
end

function movement.newGrid(cols, rows)
    local grid = {
        cellSize = movement._cellSize
    }
    
    if cols and rows then
        grid.cols = cols
        grid.rows = rows
        grid.width = cols * grid.cellSize
        grid.height = rows * grid.cellSize
    else
        local windowWidth, windowHeight = love.window.getMode()
        grid.cols = math.floor(windowWidth / grid.cellSize)
        grid.rows = math.floor(windowHeight / grid.cellSize)
        grid.width = grid.cols * grid.cellSize
        grid.height = grid.rows * grid.cellSize
    end
    
    return grid
end

function movement.newActor(style, grid, startCol, startRow, config)
    config = config or {}
    
    local actor = {
        style = style or movement.GRID,
        grid = grid or movement.newGrid(),
        
        col = startCol or 1,
        row = startRow or 1,
        
        x = 0,
        y = 0,
        
        targetX = 0,
        targetY = 0,
        slideSpeed = config.slideSpeed or 200, 
        isSliding = false,
        
        inputDelay = config.inputDelay or 0.2, 
        inputTimer = 0,
        
        normalSpeed = config.normalSpeed or 200
    }
    
    actor.x = (actor.col - 1) * actor.grid.cellSize
    actor.y = (actor.row - 1) * actor.grid.cellSize
    actor.targetX = actor.x
    actor.targetY = actor.y
    
    function actor:update(dt)
        if self.inputTimer > 0 then
            self.inputTimer = self.inputTimer - dt
        end
        
        if self.style == movement.GRID then
            self:updateGrid(dt)
        elseif self.style == movement.TILED then
            self:updateTiled(dt)
        elseif self.style == movement.NORMAL then
            self:updateNormal(dt)
        end
    end
    
    function actor:updateGrid(dt)
        local dx, dy = 0, 0
        if love.keyboard.isDown("up") or love.keyboard.isDown("w") then dy = -1
        elseif love.keyboard.isDown("down") or love.keyboard.isDown("s") then dy = 1
        elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then dx = -1
        elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then dx = 1
        end
        
        if (dx ~= 0 or dy ~= 0) and self.inputTimer <= 0 then
            local nextCol = math.max(1, math.min(self.grid.cols, self.col + dx))
            local nextRow = math.max(1, math.min(self.grid.rows, self.row + dy))
            
            self.col = nextCol
            self.row = nextRow
            
            self.x = (self.col - 1) * self.grid.cellSize
            self.y = (self.row - 1) * self.grid.cellSize
            
            self.inputTimer = self.inputDelay
        end
    end
    
    function actor:updateTiled(dt)
        if not self.isSliding then
            local dx, dy = 0, 0
            if love.keyboard.isDown("up") or love.keyboard.isDown("w") then dy = -1
            elseif love.keyboard.isDown("down") or love.keyboard.isDown("s") then dy = 1
            elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then dx = -1
            elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then dx = 1
            end
            
            if dx ~= 0 or dy ~= 0 then
                local nextCol = math.max(1, math.min(self.grid.cols, self.col + dx))
                local nextRow = math.max(1, math.min(self.grid.rows, self.row + dy))
                
                if nextCol ~= self.col or nextRow ~= self.row then
                    self.col = nextCol
                    self.row = nextRow
                    self.targetX = (self.col - 1) * self.grid.cellSize
                    self.targetY = (self.row - 1) * self.grid.cellSize
                    self.isSliding = true
                end
            end
        else
            local step = self.slideSpeed * dt
            
            if self.x < self.targetX then self.x = math.min(self.targetX, self.x + step)
            elseif self.x > self.targetX then self.x = math.max(self.targetX, self.x - step) end
            
            if self.y < self.targetY then self.y = math.min(self.targetY, self.y + step)
            elseif self.y > self.targetY then self.y = math.max(self.targetY, self.y - step) end
            
            if self.x == self.targetX and self.y == self.targetY then
                self.isSliding = false
            end
        end
    end
    
    function actor:updateNormal(dt)
        local dx, dy = 0, 0
        if love.keyboard.isDown("up") or love.keyboard.isDown("w") then dy = dy - 1 end
        if love.keyboard.isDown("down") or love.keyboard.isDown("s") then dy = dy + 1 end
        if love.keyboard.isDown("left") or love.keyboard.isDown("a") then dx = dx - 1 end
        if love.keyboard.isDown("right") or love.keyboard.isDown("d") then dx = dx + 1 end
        
        if dx ~= 0 or dy ~= 0 then
            local len = math.sqrt(dx * dx + dy * dy)
            dx = dx / len
            dy = dy / len
            
            self.x = self.x + dx * self.normalSpeed * dt
            self.y = self.y + dy * self.normalSpeed * dt
        
            local windowWidth, windowHeight = love.window.getMode()
            self.x = math.max(0, math.min(windowWidth - self.grid.cellSize, self.x))
            self.y = math.max(0, math.min(windowHeight - self.grid.cellSize, self.y))
        end
    end
    
    function actor:draw()
        love.graphics.rectangle("fill", self.x, self.y, self.grid.cellSize, self.grid.cellSize)
    end
    
    return actor
end

return movement
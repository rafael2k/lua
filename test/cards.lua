--aceydeucy.lua
--[[
  Displays the intro to the game
  ACEY DUCEY CARD GAME - Ported from BASIC to Lua
  by Jason Wraxall
  byteclub.com.au
]]
function showIntro()

  print [[
********* ACEY DUCEY CARD GAME
CREATIVE COMPUTING  MORRISTOWN, NEW JERSEY

ACEY-DUCEY IS PLAYED IN THE FOLLOWING MANNER
THE DEALER (COMPUTER) DEALS TWO CARDS FACE UP
YOU HAVE AN OPTION TO BET OR NOT BET DEPENDING
ON WHETHER OR NOT YOU FEEL THE CARD WILL HAVE
A VALUE BETWEEN THE FIRST TWO.
IF YOU DO NOT WANT TO BET, ENTER A $0 BET
]]

end

--[[
  Initialises the global bankBalance and random number generator
]]
function initGame()

 bankBalance = 100

 math.randomseed( os.time() )
end

--[[
  shows the card type
]]
function showCard(val)
  local cards={ nil, 2, 3, 4, 5, 6, 7, 8, 9, 10, "JACK", "QUEEN", "KING", "ACE"}
  return cards[val]
  end

--[[
  Displays the current bank balance (global)
]]
function showBalance()

print("YOU NOW HAVE "..bankBalance.." DOLLARS.")
print()
end

--[[
  Adjusts the global balance
]]
function adjustBalance( amount )
  bankBalance = bankBalance + amount
  showBalance()
end

--[[
  Generates a random card
]]
function dealCard()
  local nextCardValue = math.random(2,14)
  return nextCardValue
  end

--[[
  Deals cards returns a collection of two
]]
function dealCards()
 print("HERE ARE THE NEXT TWO CARDS:")
 local cardValues = {first=dealCard(),second=dealCard()}
 print( "First Card:" .. showCard(cardValues.first) )
 print( "Second Card:" .. showCard(cardValues.second) )

return cardValues

end

--[[
  Inputs a bet value
]]
function getBet()

  betOK = false
  local betAmount = 0

  -- Loop to get a valid bet or a zero bet
  repeat
  io.write("WHAT IS YOUR BET:");
  local amount = io.read();
  betAmount = tonumber(amount)
  if betAmount==0 then
    print("CHICKEN!!")
    print()
    betOK = true
  end
  if betAmount <= bankBalance then
      betOK = true
    else
      print("SORRY, MY FRIEND, BUT YOU BET TOO MUCH.")
      print("YOU HAVE ONLY " .. bankBalance .. " DOLLARS TO BET.")
    end
  until betOK

    return betAmount
end

--[[
  Deals another card and compares values
]]
function playRound( cardValues )
  local playerCard = dealCard()
  local firstCard = cardValues.first
  local secondCard = cardValues.second

  print( "Dealer Card" .. showCard(playerCard) )

  local minValue = math.min( firstCard, secondCard )
  local maxValue = math.max( firstCard, secondCard )

  if playerCard>=minValue and playerCard <=maxValue then
    print("YOU WIN!!!")
    return true
  end

  print("You Lose!!")
  return false
end


function endGameReplay()

  print[[
  SORRY, FRIEND, BUT YOU BLEW YOUR WAD.

  ]]

  io.write("TRY AGAIN (Y/N)")
  response = io.read()
  if repsonse == "Y" then
    return true
  else
    print("O.K., HOPE YOU HAD FUN!")
    return false
  end

end

-- Main Loop - Here's when the action happens

showIntro()

done = false -- when true the game loop ends

initGame()

-- Game Loop
repeat
    local cardValues = dealCards()
    local betAmount = getBet()

    if betAmount == 0 then
      done=true -- user said they don't want to play anymore
    else
      if playRound(cardValues) then
        adjustBalance( betAmount )
      else
        adjustBalance( -betAmount )

        -- if no more money then ask to start again
        if bankBalance <= 0 then
          if endGameReplay()==true then
            -- start again
            initGame() -- reset variables
          end
          done=true
          end
      end
    end
  until done

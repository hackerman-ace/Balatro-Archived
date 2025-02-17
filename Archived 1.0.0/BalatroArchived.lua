--- STEAMODDED HEADER
--- MOD_NAME: Balatro Archived
--- MOD_ID: BalatroArchived
--- MOD_AUTHOR: [Crimson Heart]
--- MOD_DESCRIPTION: What if you could use cards from one version with jokers from another? NOTE: Everything is based on how they are in the older code. It's not 1:1, but does reference any code available. 
--- DISPLAY_NAME: Archived
--- BADGE_COLOUR: b20a2f
--- DEPENDENCIES: [Steamodded>=1.0.0~ALPHA-1103a, ShinkuLib>=1.0]
--- PREFIX: archived
----------------------------------------------
------------MOD CODE -------------------------

------------  Essentials  --------------------

--------  Atlas  --------------------

SMODS.Atlas({key = 'ArchivedTarots', path = 'ArchivedTarots.png', px = 71, py = 95, atlas_table = 'ASSET_ATLAS'})
SMODS.Atlas({key = 'ArchivedDecks', path = 'ArchivedDecks.png', px = 71, py = 95, atlas_table = 'ASSET_ATLAS'})
SMODS.Atlas({key = 'ArchivedJokers', path = 'ArchivedJokers.png', px = 71, py = 95, atlas_table = 'ASSET_ATLAS'})
SMODS.Atlas({key = 'ArchivedPlanets', path = 'ArchivedPlanets.png', px = 71, py = 95, atlas_table = 'ASSET_ATLAS'})


--------  Code  --------------------

local Backapply_to_runRef = Back.apply_to_run
function Back.apply_to_run(self)
    Backapply_to_runRef(self)
    
    if self.effect.config.start_joker then
        delay(0.4)
            G.E_MANAGER:add_event(Event({
                func = function()
                    local card = create_card('Joker', G.jokers)
                    card:add_to_deck()
                    card:start_materialize()
                    G.jokers:emplace(card)
                return true
                end
            }))
    end
        
    if self.effect.config.start_consumeable then
        delay(0.4)
        G.E_MANAGER:add_event(Event({
            func = function()
                local card = create_card('Tarot', G.consumeables)
                card:add_to_deck()
                G.consumeables:emplace(card)
                card = create_card('Planet', G.consumeables)
                card:add_to_deck()
                G.consumeables:emplace(card)
            return true
            end
        }))
    end

    if self.effect.config.most_used_hand_level then 
        local handname, amount = 'None', 0
        for k, v in pairs(G.PROFILES[G.SETTINGS.profile].hand_usage) do if v.count > amount then handname = v.order; amount = v.count end end
        if handname ~= 'None' then 
            for i = 2, self.effect.config.most_used_hand_level do
                level_up_hand(nil, handname, true)
            end
        end
    end
end

local card_draw_ref = Card.draw
function Card.draw(self, layer)
        card_draw_ref(self, layer)
        if self.sprite_facing == 'back' then
            local overlay = G.C.WHITE
            if self.area and self.area.config.type == 'deck' and self.rank > 3 then
                overlay = {0.5 + ((#self.area.cards - self.rank)%7)/50, 0.5 + ((#self.area.cards - self.rank)%7)/50, 0.5 +((#self.area.cards - self.rank)%7)/50, 1}
            end
    
            self.children.back:draw(overlay)
    
            if self.playing_card and
            ((self.b_foil or self.b_holo or self.b_polychrome) or
            G.GAME[self.back].name == 'Foil Deck [0.8.6b]' or
            G.GAME[self.back].name == 'Holographic Deck [0.8.6b]' or
            G.GAME[self.back].name == 'Polychrome Deck [0.8.6b]'
            ) and
            (not self.area or 
            (self == self.area.cards[1] or
            self == self.area.cards[2] or
            math.abs(self.velocity.x)+math.abs(self.velocity.y) > 0.1)) then
                if G.GAME[self.back].name == 'Foil Deck [0.8.6b]' or self.b_foil then
                    self.children.back:draw_shader('foil', nil, self.ARGS.send_to_shader, true)
                end
                if G.GAME[self.back].name == 'Polychrome Deck [0.8.6b]' or self.b_polychrome  then 
                    self.children.back:draw_shader('polychrome', nil, self.ARGS.send_to_shader, true)
                end
                if G.GAME[self.back].name == 'Holographic Deck [0.8.6b]' or self.b_holo then 
                    self.children.back:draw_shader('holo', nil, self.ARGS.send_to_shader, true)
                end
            end
            love.graphics.setColor(G.C.WHITE)
        end
end

------------  0.8.6  -------------------------

--------  Blinds  --------------------

-- Down the line

--------  Jokers  --------------------

SMODS.Joker {
    key = 'j_joker_086b',
    loc_txt = {
      name = 'Joker [0.8.6b]',
      text = {
        "{C:mult}+#1#{} Mult"
      }
    },
    config = { extra = { mult = 4 } },
    loc_vars = function(self, info_queue, card)
      return { vars = { card.ability.extra.mult } }
    end,
    rarity = 1,
    unlocked = true,
    discovered = true,
    atlas = 'ArchivedJokers',
    pos = { x = 0, y = 0 },
    cost = 3,
    calculate = function(self, card, context)
      if context.joker_main then
        return {
          mult_mod = card.ability.extra.mult,
          message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } }
        }
      end
    end
  }

SMODS.Joker {
  key = 'j_jolly_086b',
  loc_txt = {
    name = 'Jolly Joker [0.8.6b]',
    text = {
      "{C:red}+#1#{} Mult if played",
      "hand contains",
      "a {C:attention}#2#"
      }
  },
  config = { extra = {t_mult = 5, type = 'Pair'} },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.t_mult, card.ability.extra.type } }
  end,
  rarity = 1,
  unlocked = true,
  discovered = true,
  atlas = 'ArchivedJokers',
  pos = { x = 2, y = 0 },
  cost = 3,
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and not context.before and not context.after and context.poker_hands and next(context.poker_hands["Pair"]) then
      return {
        message = localize({ type = "variable", key = "a_mult", vars = { card.ability.extra.t_mult } }),
        colour = G.C.RED,
        mult_mod = card.ability.extra.t_mult,
      }
      end
  end,
}

SMODS.Joker {
  key = 'j_zany_086b',
  loc_txt = {
    name = 'Zany Joker [0.8.6b]',
    text = {
      "{C:red}+#1#{} Mult if played",
      "hand contains",
      "a {C:attention}#2#"
      }
  },
  config = { extra = {t_mult = 7, type = 'Three of a Kind'} },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.t_mult, card.ability.extra.type } }
  end,
  rarity = 1,
  unlocked = true,
  discovered = true,
  atlas = 'ArchivedJokers',
  pos = { x = 3, y = 0 },
  cost = 3,
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and not context.before and not context.after and context.poker_hands and next(context.poker_hands["Three of a Kind"]) then
      return {
        message = localize({ type = "variable", key = "a_mult", vars = { card.ability.extra.t_mult } }),
        colour = G.C.RED,
        mult_mod = card.ability.extra.t_mult,
      }
      end
  end,
}
    
SMODS.Joker {
  key = 'j_mad_086b',
  loc_txt = {
    name = 'Mad Joker [0.8.6b]',
    text = {
      "{C:red}+#1#{} Mult if played",
      "hand contains",
      "a {C:attention}#2#"
      }
  },
  config = { extra = {t_mult = 10, type = 'Four of a Kind'} },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.t_mult, card.ability.extra.type } }
  end,
  rarity = 1,
  unlocked = true,
  discovered = true,
  atlas = 'ArchivedJokers',
  pos = { x = 4, y = 0 },
  cost = 3,
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and not context.before and not context.after and context.poker_hands and next(context.poker_hands["Four of a Kind"]) then
      return {
        message = localize({ type = "variable", key = "a_mult", vars = { card.ability.extra.t_mult } }),
        colour = G.C.RED,
        mult_mod = card.ability.extra.t_mult,
      }
      end
  end,
}

SMODS.Joker {
  key = 'j_crazy_086b',
  loc_txt = {
    name = 'Crazy Joker [0.8.6b]',
    text = {
      "{C:red}+#1#{} Mult if played",
      "hand contains",
      "a {C:attention}#2#"
      }
  },
  config = { extra = {t_mult = 7, type = 'Straight'} },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.t_mult, card.ability.extra.type } }
  end,
  rarity = 1,
  unlocked = true,
  discovered = true,
  atlas = 'ArchivedJokers',
  pos = { x = 5, y = 0 },
  cost = 3,
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and not context.before and not context.after and context.poker_hands and next(context.poker_hands["Straight"]) then
      return {
        message = localize({ type = "variable", key = "a_mult", vars = { card.ability.extra.t_mult } }),
        colour = G.C.RED,
        mult_mod = card.ability.extra.t_mult,
      }
      end
  end,
}

SMODS.Joker {
  key = 'j_droll_086b',
  loc_txt = {
    name = 'Droll Joker [0.8.6b]',
    text = {
      "{C:red}+#1#{} Mult if played",
      "hand contains",
      "a {C:attention}#2#"
      }
  },
  config = { extra = {t_mult = 7, type = 'Flush'} },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.t_mult, card.ability.extra.type } }
  end,
  rarity = 1,
  unlocked = true,
  discovered = true,
  atlas = 'ArchivedJokers',
  pos = { x = 6, y = 0 },
  cost = 3,
   calculate = function(self, card, context)
    if context.cardarea == G.jokers and not context.before and not context.after and context.poker_hands and next(context.poker_hands["Flush"]) then
      return {
        message = localize({ type = "variable", key = "a_mult", vars = { card.ability.extra.t_mult } }),
        colour = G.C.RED,
        mult_mod = card.ability.extra.t_mult,
      }
      end
  end,
}


SMODS.Joker {
    key = 'greedy_joker_086b',
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = false,
    rental_compat = false,
    unlocked = true,
    discovered = true,
    loc_txt = {
        name = 'Greedy Joker [0.8.6b]',
        text = { "Played cards with",
                 "{C:diamonds}#2#{} suit give",
                 "{C:mult}+#1#{} Mult when scored"
            }
    },
    effect = 'Suit Mult',
    config = {
        extra = {
            s_mult = 2,
            suit = 'Diamonds',
        },
    },
    atlas = 'ArchivedJokers',
    pos = { x = 6, y = 1 },
    cost = 5,
    loc_vars = function(self, info_queue, card)
        return {
            vars = { card.ability.extra.s_mult, localize(card.ability.extra.suit, 'suits_singular') }
        }
    end
}

SMODS.Joker {
    key = 'lusty_joker_086b',
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = false,
    rental_compat = false,
    unlocked = true,
    discovered = true,
    loc_txt = {
        name = 'Lusty Joker [0.8.6b]',
        text = { "Played cards with",
                 "{C:hearts}#2#{} suit give",
                 "{C:mult}+#1#{} Mult when scored"
            }
    },
    effect = 'Suit Mult',
    config = {
        extra = {
            s_mult = 2,
            suit = 'Hearts',
        },
    },
    atlas = 'ArchivedJokers',
    pos = { x = 7, y = 1 },
    cost = 5,
    loc_vars = function(self, info_queue, card)
        return {
            vars = { card.ability.extra.s_mult, localize(card.ability.extra.suit, 'suits_singular') }
        }
    end
}

SMODS.Joker {
    key = 'wrathful_joker_086b',
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = false,
    rental_compat = false,
    unlocked = true,
    discovered = true,
    loc_txt = {
        name = 'Wrathful Joker [0.8.6b]',
        text = { "Played cards with",
                 "{C:spades}#2#{} suit give",
                 "{C:mult}+#1#{} Mult when scored"
            }
    },
    effect = 'Suit Mult',
    config = {
        extra = {
            s_mult = 2,
            suit = 'Spades',
        },
    },
    atlas = 'ArchivedJokers',
    pos = { x = 8, y = 1 },
    cost = 5,
    loc_vars = function(self, info_queue, card)
        return {
            vars = { card.ability.extra.s_mult, localize(card.ability.extra.suit, 'suits_singular') }
        }
    end
}

SMODS.Joker {
    key = 'gluttonous_joker_086b',
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = false,
    rental_compat = false,
    unlocked = true,
    discovered = true,
    loc_txt = {
        name = 'Gluttonous Joker [0.8.6b]',
        text = { "Played cards with",
                 "{C:clubs}#2#{} suit give",
                 "{C:mult}+#1#{} Mult when scored"
            }
    },
    effect = 'Suit Mult',
    config = {
        extra = {
            s_mult = 2,
            suit = 'Clubs',
        },
    },
    atlas = 'ArchivedJokers',
    pos = { x = 9, y = 1 },
    cost = 5,
    loc_vars = function(self, info_queue, card)
        return {
            vars = { card.ability.extra.s_mult, localize(card.ability.extra.suit, 'suits_singular') }
        }
    end
}

--------  Tarots  --------------------

-- Code Here

--------  Planets  -------------------

SMODS.Consumable{
  key = 'mercury_086b',
  set = 'Planet',
  pos = {x = 0, y = 0},
  config = {hand_type = 'Pair', extra = {planet_chips = 10, planet_mult = 1}},
  cost = 3,
  order = 1,
  atlas = 'ArchivedPlanets',
  loc_txt = {
    name = 'Mercury [0.8.6b]',
    text = { 
      "{S:0.8}({S:0.8,V:1}lvl.#2#{S:0.8}){} Level up",
      "{C:attention}#1#",
      "{C:mult}+#3#{} Mult and",
      "{C:chips}+#4#{} chips",
  },
  },
	can_use = function(self, card)
		return true
	end,

  loc_vars = function(self, info_queue, center)
    local planetlevel = G.GAME.hands['Pair'].level or 1
    local planetcolor = G.C.HAND_LEVELS[math.min(planetlevel, 7)]
    if planetlevel == 1 then
        planetcolor = G.C.UI.TEXT_DARK
    end
    return {
    vars = {
      localize("Pair", "poker_hands"),
      G.GAME.hands['Pair'].level,
      self.config.extra.planet_mult,
      self.config.extra.planet_chips,
      colours = { planetcolor },
    },
    }
  end,
  use = function(self, card, area, copier)
    update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(card.ability.consumeable.hand_type, 'poker_hands'),chips = G.GAME.hands[card.ability.consumeable.hand_type].chips, mult = G.GAME.hands[card.ability.consumeable.hand_type].mult, level=G.GAME.hands[card.ability.consumeable.hand_type].level})
    Shinku_LUH(card, card.ability.hand_type, nil, 1)
    update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
  end,
}


SMODS.Consumable{
  key = 'venus_086b',
  set = 'Planet',
  pos = {x = 1, y = 0},
  config = {hand_type = 'Three of a Kind', extra = {planet_chips = 10, planet_mult = 1}},
  cost = 3,
  order = 2,
  atlas = 'ArchivedPlanets',
  loc_txt = {
    name = 'Venus [0.8.6b]',
    text = { 
      "{S:0.8}({S:0.8,V:1}lvl.#2#{S:0.8}){} Level up",
      "{C:attention}#1#",
      "{C:mult}+#3#{} Mult and",
      "{C:chips}+#4#{} chips",
  },
  },
	can_use = function(self, card)
		return true
	end,

  loc_vars = function(self, info_queue, center)
    local planetlevel = G.GAME.hands['Three of a Kind'].level or 1
    local planetcolor = G.C.HAND_LEVELS[math.min(planetlevel, 7)]
    if planetlevel == 1 then
        planetcolor = G.C.UI.TEXT_DARK
    end
    return {
    vars = {
      localize("Three of a Kind", "poker_hands"),
      G.GAME.hands['Three of a Kind'].level,
      self.config.extra.planet_mult,
      self.config.extra.planet_chips,
      colours = { planetcolor },
    },
    }
  end,
  use = function(self, card, area, copier)
    update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(card.ability.consumeable.hand_type, 'poker_hands'),chips = G.GAME.hands[card.ability.consumeable.hand_type].chips, mult = G.GAME.hands[card.ability.consumeable.hand_type].mult, level=G.GAME.hands[card.ability.consumeable.hand_type].level})
    Shinku_LUH(card, card.ability.hand_type, nil, 1)
    update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
  end,
}

SMODS.Consumable{
  key = 'Earth_086b',
  set = 'Planet',
  pos = {x = 2, y = 0},
  config = {hand_type = 'Full House', extra = {planet_chips = 20, planet_mult = 1}},
  cost = 3,
  order = 3,
  atlas = 'ArchivedPlanets',
  loc_txt = {
    name = 'Earth [0.8.6b]',
    text = { 
      "{S:0.8}({S:0.8,V:1}lvl.#2#{S:0.8}){} Level up",
      "{C:attention}#1#",
      "{C:mult}+#3#{} Mult and",
      "{C:chips}+#4#{} chips",
  },
  },
	can_use = function(self, card)
		return true
	end,

  loc_vars = function(self, info_queue, center)
    local planetlevel = G.GAME.hands['Full House'].level or 1
    local planetcolor = G.C.HAND_LEVELS[math.min(planetlevel, 7)]
    if planetlevel == 1 then
        planetcolor = G.C.UI.TEXT_DARK
    end
    return {
    vars = {
      localize("Full House", "poker_hands"),
      G.GAME.hands['Full House'].level,
      self.config.extra.planet_mult,
      self.config.extra.planet_chips,
      colours = { planetcolor },
    },
    }
  end,
  use = function(self, card, area, copier)
    update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(card.ability.consumeable.hand_type, 'poker_hands'),chips = G.GAME.hands[card.ability.consumeable.hand_type].chips, mult = G.GAME.hands[card.ability.consumeable.hand_type].mult, level=G.GAME.hands[card.ability.consumeable.hand_type].level})
    Shinku_LUH(card, card.ability.hand_type, nil, 1)
    update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
  end,
}

SMODS.Consumable{
  key = 'mars_086b',
  set = 'Planet',
  pos = {x = 3, y = 0},
  config = {hand_type = 'Four of a Kind', extra = {planet_chips = 20, planet_mult = 2}},
  cost = 3,
  order = 4,
  atlas = 'ArchivedPlanets',
  loc_txt = {
    name = 'Mars [0.8.6b]',
    text = { 
      "{S:0.8}({S:0.8,V:1}lvl.#2#{S:0.8}){} Level up",
      "{C:attention}#1#",
      "{C:mult}+#3#{} Mult and",
      "{C:chips}+#4#{} chips",
  },
  },
	can_use = function(self, card)
		return true
	end,

  loc_vars = function(self, info_queue, center)
    local planetlevel = G.GAME.hands['Four of a Kind'].level or 1
    local planetcolor = G.C.HAND_LEVELS[math.min(planetlevel, 7)]
    if planetlevel == 1 then
        planetcolor = G.C.UI.TEXT_DARK
    end
    return {
    vars = {
      localize("Four of a Kind", "poker_hands"),
      G.GAME.hands['Four of a Kind'].level,
      self.config.extra.planet_mult,
      self.config.extra.planet_chips,
      colours = { planetcolor },
    },
    }
  end,
  use = function(self, card, area, copier)
    update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(card.ability.consumeable.hand_type, 'poker_hands'),chips = G.GAME.hands[card.ability.consumeable.hand_type].chips, mult = G.GAME.hands[card.ability.consumeable.hand_type].mult, level=G.GAME.hands[card.ability.consumeable.hand_type].level})
    Shinku_LUH(card, card.ability.hand_type, nil, 1)
    update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
  end,
}

SMODS.Consumable{
  key = 'Jupiter_086b',
  set = 'Planet',
  pos = {x = 4, y = 0},
  config = {hand_type = 'Flush', extra = {planet_chips = 10, planet_mult = 1}},
  cost = 3,
  order = 5,
  atlas = 'ArchivedPlanets',
  loc_txt = {
    name = 'Jupiter [0.8.6b]',
    text = { 
      "{S:0.8}({S:0.8,V:1}lvl.#2#{S:0.8}){} Level up",
      "{C:attention}#1#",
      "{C:mult}+#3#{} Mult and",
      "{C:chips}+#4#{} chips",
  },
  },
	can_use = function(self, card)
		return true
	end,

  loc_vars = function(self, info_queue, center)
    local planetlevel = G.GAME.hands['Flush'].level or 1
    local planetcolor = G.C.HAND_LEVELS[math.min(planetlevel, 7)]
    if planetlevel == 1 then
        planetcolor = G.C.UI.TEXT_DARK
    end
    return {
    vars = {
      localize("Flush", "poker_hands"),
      G.GAME.hands['Flush'].level,
      self.config.extra.planet_mult,
      self.config.extra.planet_chips,
      colours = { planetcolor },
    },
    }
  end,
  use = function(self, card, area, copier)
    update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(card.ability.consumeable.hand_type, 'poker_hands'),chips = G.GAME.hands[card.ability.consumeable.hand_type].chips, mult = G.GAME.hands[card.ability.consumeable.hand_type].mult, level=G.GAME.hands[card.ability.consumeable.hand_type].level})
    Shinku_LUH(card, card.ability.hand_type, nil, 1)
    update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
  end,
}

SMODS.Consumable{
  key = 'Saturn_086b',
  set = 'Planet',
  pos = {x = 5, y = 0},
  config = {hand_type = 'Straight', extra = {planet_chips = 10, planet_mult = 1}},
  cost = 3,
  order = 6,
  atlas = 'ArchivedPlanets',
  loc_txt = {
    name = 'Saturn [0.8.6b]',
    text = { 
      "{S:0.8}({S:0.8,V:1}lvl.#2#{S:0.8}){} Level up",
      "{C:attention}#1#",
      "{C:mult}+#3#{} Mult and",
      "{C:chips}+#4#{} chips",
  },
  },
	can_use = function(self, card)
		return true
	end,

  loc_vars = function(self, info_queue, center)
    local planetlevel = G.GAME.hands['Straight'].level or 1
    local planetcolor = G.C.HAND_LEVELS[math.min(planetlevel, 7)]
    if planetlevel == 1 then
        planetcolor = G.C.UI.TEXT_DARK
    end
    return {
    vars = {
      localize("Straight", "poker_hands"),
      G.GAME.hands['Straight'].level,
      self.config.extra.planet_mult,
      self.config.extra.planet_chips,
      colours = { planetcolor },
    },
    }
  end,
  use = function(self, card, area, copier)
    update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(card.ability.consumeable.hand_type, 'poker_hands'),chips = G.GAME.hands[card.ability.consumeable.hand_type].chips, mult = G.GAME.hands[card.ability.consumeable.hand_type].mult, level=G.GAME.hands[card.ability.consumeable.hand_type].level})
    Shinku_LUH(card, card.ability.hand_type, nil, 1)
    update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
  end,
}

SMODS.Consumable{
  key = 'Uranus_086b',
  set = 'Planet',
  pos = {x = 6, y = 0},
  config = {hand_type = 'Two Pair', extra = {planet_chips = 10, planet_mult = 1}},
  cost = 3,
  order = 7,
  atlas = 'ArchivedPlanets',
  loc_txt = {
    name = 'Uranus [0.8.6b]',
    text = { 
      "{S:0.8}({S:0.8,V:1}lvl.#2#{S:0.8}){} Level up",
      "{C:attention}#1#",
      "{C:mult}+#3#{} Mult and",
      "{C:chips}+#4#{} chips",
  },
  },
	can_use = function(self, card)
		return true
	end,

  loc_vars = function(self, info_queue, center)
    local planetlevel = G.GAME.hands['Two Pair'].level or 1
    local planetcolor = G.C.HAND_LEVELS[math.min(planetlevel, 7)]
    if planetlevel == 1 then
        planetcolor = G.C.UI.TEXT_DARK
    end
    return {
    vars = {
      localize("Two Pair", "poker_hands"),
      G.GAME.hands['Two Pair'].level,
      self.config.extra.planet_mult,
      self.config.extra.planet_chips,
      colours = { planetcolor },
    },
    }
  end,
  use = function(self, card, area, copier)
    update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(card.ability.consumeable.hand_type, 'poker_hands'),chips = G.GAME.hands[card.ability.consumeable.hand_type].chips, mult = G.GAME.hands[card.ability.consumeable.hand_type].mult, level=G.GAME.hands[card.ability.consumeable.hand_type].level})
    Shinku_LUH(card, card.ability.hand_type, nil, 1)
    update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
  end,
}

SMODS.Consumable{
  key = 'Neptune_086b',
  set = 'Planet',
  pos = {x = 7, y = 0},
  config = {hand_type = 'Straight Flush', extra = {planet_chips = 25, planet_mult = 2}},
  cost = 3,
  order = 8,
  atlas = 'ArchivedPlanets',
  loc_txt = {
    name = 'Neptune [0.8.6b]',
    text = { 
      "{S:0.8}({S:0.8,V:1}lvl.#2#{S:0.8}){} Level up",
      "{C:attention}#1#",
      "{C:mult}+#3#{} Mult and",
      "{C:chips}+#4#{} chips",
  },
  },
	can_use = function(self, card)
		return true
	end,

  loc_vars = function(self, info_queue, center)
    local planetlevel = G.GAME.hands['Straight Flush'].level or 1
    local planetcolor = G.C.HAND_LEVELS[math.min(planetlevel, 7)]
    if planetlevel == 1 then
        planetcolor = G.C.UI.TEXT_DARK
    end
    return {
    vars = {
      localize("Straight Flush", "poker_hands"),
      G.GAME.hands['Straight Flush'].level,
      self.config.extra.planet_mult,
      self.config.extra.planet_chips,
      colours = { planetcolor },
    },
    }
  end,
  use = function(self, card, area, copier)
    update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(card.ability.consumeable.hand_type, 'poker_hands'),chips = G.GAME.hands[card.ability.consumeable.hand_type].chips, mult = G.GAME.hands[card.ability.consumeable.hand_type].mult, level=G.GAME.hands[card.ability.consumeable.hand_type].level})
    Shinku_LUH(card, card.ability.hand_type, nil, 1)
    update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
  end,
}

SMODS.Consumable{
  key = 'Pluto_086b',
  set = 'Planet',
  pos = {x = 8, y = 0},
  config = {hand_type = 'High Card', extra = {planet_chips = 5, planet_mult = 1}},
  cost = 3,
  order = 9,
  atlas = 'ArchivedPlanets',
  loc_txt = {
    name = 'Pluto [0.8.6b]',
    text = { 
      "{S:0.8}({S:0.8,V:1}lvl.#2#{S:0.8}){} Level up",
      "{C:attention}#1#",
      "{C:mult}+#3#{} Mult and",
      "{C:chips}+#4#{} chips",
  },
  },
	can_use = function(self, card)
		return true
	end,

  loc_vars = function(self, info_queue, center)
    local planetlevel = G.GAME.hands['High Card'].level or 1
    local planetcolor = G.C.HAND_LEVELS[math.min(planetlevel, 7)]
    if planetlevel == 1 then
        planetcolor = G.C.UI.TEXT_DARK
    end
    return {
    vars = {
      localize("High Card", "poker_hands"),
      G.GAME.hands['High Card'].level,
      self.config.extra.planet_mult,
      self.config.extra.planet_chips,
      colours = { planetcolor },
    },
    }
  end,
  use = function(self, card, area, copier)
    update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(card.ability.consumeable.hand_type, 'poker_hands'),chips = G.GAME.hands[card.ability.consumeable.hand_type].chips, mult = G.GAME.hands[card.ability.consumeable.hand_type].mult, level=G.GAME.hands[card.ability.consumeable.hand_type].level})
    Shinku_LUH(card, card.ability.hand_type, nil, 1)
    update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
  end,
}


--------  Vouchers  ------------------

--[[SMODS.Voucher {
  key = 'crystal_ball_086b',
  unlocked = true,
  discovered = true,
  loc_txt = {
      name = 'Crystal Ball [0.8.6b]',
      text = { "{s:1.2}Unlocks {}{C:tarot,s:1.2}Tarot Reading{}",
               "Once per round gives",
               "one of {C:attention}2 {C:tarot}Tarot{} cards"
          }
  },
  config = {},
  pos = { x = 2, y = 2 },
  cost = 10,
}

SMODS.Voucher {
  key = 'omen_globe_086b',
  unlocked = true,
  discovered = true,
  loc_txt = {
      name = 'Omen Globe [0.8.6b]',
      text = { "{s:1.2}Upgrade {}{C:tarot,s:1.2}Tarot Reading{}",
               "Once per round gives",
               "one of {C:attention}4 {C:tarot}Tarot{} cards"
          }
  },
  config = {},
  pos = { x = 2, y = 3 },
  cost = 10,
  requires = 'v_archived_crystal_ball_086b',
}
  ]]--

--------  Editions  ------------------

-- Code Here

--------  Decks  ---------------------

SMODS.Back({
  key = 'red_086b',
  atlas = 'ArchivedDecks',
  pos = {x = 5, y = 1},
  config = {discards = 1},
  loc_txt = {
    name = 'Red Deck [0.8.6b]',
    text = { "{C:red}+#1#{} discard",
           "every round"
        }
},
  loc_vars = function(self, info_queue, card)
    return {vars = {self.config.discards}}
  end
})

SMODS.Back({
  key = 'blue_086b',
  atlas = 'ArchivedDecks',
  pos = {x = 0, y = 0},
  config = {hands = 1},
  loc_txt = {
    name = 'Blue Deck [0.8.6b]',
    text = { "{C:blue}+#1#{} hand",
           "every round"
        }
},
  loc_vars = function(self, info_queue, card)
    return {vars = {self.config.hands}}
  end
})

SMODS.Back({
  key = 'yellow_086b',
  atlas = 'ArchivedDecks',
  pos = {x = 1, y = 0},
  config = {dollars = 10},
  loc_txt = {
    name = 'Yellow Deck [0.8.6b]',
    text = { "Start with",
           "extra {C:money}$#1#{}"
        }
},
  loc_vars = function(self, info_queue, card)
    return {vars = {self.config.dollars}}
  end
})


SMODS.Back({
  key = 'green_086b',
  atlas = 'ArchivedDecks',
  pos = {x = 2, y = 0},
  config = {reroll_discount = 1},
  loc_txt = {
    name = 'Green Deck [0.8.6b]',
    text = {
      "Rerolls cost",
      "one {C:money}$#1#{} less",
    }
},
  loc_vars = function(self, info_queue, card)
    return {vars = {self.config.reroll_discount}}
  end
})





--------  Enhancements  --------------

-- Code Here

----------------------------------------------
------------MOD CODE END----------------------
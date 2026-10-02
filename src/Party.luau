--!strict
type party_data = {
    members: {
        [Player]: {
            Role: number,
            Ready: boolean,
        },
    },
}

local Party = { }
local active_partys: {[number]: party_data} = { }

function Party.new(leader: Player): number
    local current_party = Party.GetPartyIdFromMember(leader)
    if current_party ~= nil then
        return current_party
    end

    local party: party_data = {
        members = {
            [leader] = {
                Role = 2,
                Ready = false,
            }
        }
    }

    local index = #active_partys + 1
    active_partys[index] = party

    return index
end

function Party.getMemberCount(partyId: number): number
    local party = active_partys[partyId]
    if party then
        local count = 0

        for _ in party.members do
            count += 1
        end
        return count
    end

    return 0
end

function Party.isPartyReady(partyId: number): boolean
    local party = active_partys[partyId]
    if party then
        for _, data in party.members do
            if not data.Ready then
                return false
            end
        end

        return true
    end

    return false
end

function Party.GetPartyIdFromMember(player: Player): number?
    for i, v in active_partys do
        if v.members[player] then
            return i
        end
    end

    return nil
end

function Party.addMember(partyId: number, player: Player)
    local party = active_partys[partyId]
    if party then
        local data = {
            Role = 1,
            Ready = false,
        }

        party.members[player] = data
    end
end

function Party.get(partyId: number): party_data?
    return active_partys[partyId]
end

function Party.Ready(player: Player): boolean
    local partyId = Party.GetPartyIdFromMember(player)
    if not partyId then
        return false
    end

    local party = active_partys[partyId]
    if party then
        local memberData = party.members[player]
        if memberData then
            memberData.Ready = true
            return true
        end
    end

    return false
end

function Party.Unready(player: Player): boolean
    local partyId = Party.GetPartyIdFromMember(player)
    if not partyId then
        return false
    end

    local party = active_partys[partyId]
    if party then
        local memberData = party.members[player]
        if memberData then
            memberData.Ready = false
            return true
        end
    end

    return false
end

function Party.getMembers(partyId: number): {Player}?
    local party = active_partys[partyId]
    if party then
        local members = {}

        for player, data in party.members do
            table.insert(members, player)
        end

        return members
    end

    return nil
end

function Party.removeMember(partyId: number, player: Player)
    local party = active_partys[partyId]
    if party then
        party.members[player] = nil
    end
end

function Party.destroy(partyId: number)
    if active_partys[partyId] then
        active_partys[partyId] = nil
    end
end

return Party

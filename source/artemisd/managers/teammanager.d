module artemisd.managers.teammanager;

import artemisd.entity;
import artemisd.manager;
import artemisd.utils.bag;
import artemisd.utils.type;
import artemisd.utils.ext;


class TeamManager : Manager 
{
    mixin TypeDecl;

    private Bag!string[string] playersByTeam;
    private string[string] teamByPlayer;

    protected override void initialize() 
    {
    }
    
    string getTeam(string player) 
    {
        return teamByPlayer.get(player,"");
    }
    
    void setTeam(string player, string team) 
    {
        removeFromTeam(player);
        teamByPlayer[player]=team;
        
        auto players = playersByTeam.getWithDefault(team, new Bag!string);
        players.add(player);
    }
    
    Bag!string getPlayers(string team) 
    {
        return playersByTeam.getWithDefault(team, new Bag!string);
    }
    
    void removeFromTeam(string player) 
    {
        auto team = player in teamByPlayer;
        if( team )
        {
            teamByPlayer.remove(player);
            auto players = *team in playersByTeam;
            if( players )
            {
                players.remove(player);
            }
        }
    }
}

unittest
{
    TeamManager m = new TeamManager;
    m.setTeam("e","g1");
    m.setTeam("e1", "g1");
    assert(m.getTeam("e") == "g1");
    assert(m.getTeam("e1") == "g1");
    assert(m.getPlayers("g1").toString() == "[e,e1]");

    m.removeFromTeam("e1");
    assert(m.getTeam("e1") != "g1");
    assert(m.getPlayers("g1").toString() == "[e]");
}
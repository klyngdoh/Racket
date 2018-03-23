// A Roster is an object of any class that implements the Roster interface.
//
// A Roster object represents a set of players.
//
// Roster objects are immutable, but all players on a roster
// have mutable status, which can affect the values returned by
// the readyCount() and readyRoster() methods.
//
// If r1 and r2 are rosters, then r1.equals(r2) if and only if
// every player on roster r1 is also on roster r2, and
// every player on roster r2 is also on roster r1.
//
// If r is a roster, then r.hashcode() always returns the same
// value, even if r has some players whose status changes.
//
// If r1 and r2 are rosters of different sizes, then
// r1.toString() is not the same string as r2.toString().
//
// Rosters.empty() is a static factory method that returns an
// empty roster.

import java.util.Iterator;
import java.util.ArrayList;
import java.util.List;
import java.util.Collections;

public class Rosters implements Roster {
	
	private List<Player> playerList;
	
	Rosters(List<Player> playerList)
	{
		this.playerList=playerList;
	}
	
	// GIVEN: an object
	// RETURNS: true iff the object is an equivalent roster - If the two rosters contain the same players, regardless of order
	
	public boolean equals(Object o)
	{
		if(o instanceof Roster)
		{
			Roster r2 = (Roster) o;
			return isEqual(r2);
		}
		else
			return false;
	}
	
	// GIVEN: another roster
	// RETURNS: true iff the two rosters contain exactly the same players
	
	private boolean isEqual(Roster r2)
	{
		Iterator<Player> it1 = iterator();
		while(it1.hasNext())
		{
			Player p = it1.next();
			if(!r2.has(p))
				return false;
		}
		
		Iterator<Player> it2 = r2.iterator();
		while(it2.hasNext())
		{
			Player p = it2.next();
			if(!has(p))
				return false;
		}
		return true;
	}

	// RETURNS: The size of the roster, as a string.
	
	public String toString()
	{
		return Integer.toString(playerList.size());
	}
	
	// RETURNS: an empty roster
	
	public static Rosters empty()
	{
		List<Player> pList = new ArrayList<Player>();
		return new Rosters(pList);
	}

	// GIVEN: A player
    // RETURNS: a roster consisting of the given player together
    // 			with all players on this roster.
    // EXAMPLES:
    //     r.with(p).with(p)  =>  r.with(p)

    public Roster with (Player p)
	{
		List<Player> resultList = new ArrayList<Player>();
		resultList.addAll(playerList);
		if(!has(p))
			resultList.add(p);
		return new Rosters(resultList);
	}

	// GIVEN: A player
    // RETURNS: a roster consisting of all players on this roster
    // 			except for the given player.
    // EXAMPLES:
    //     Rosters.empty().without(p)  =>  Rosters.empty()
    //     r.without(p).without(p)     =>  r.without(p)

    public Roster without (Player p)
	{
		List<Player> resultList = new ArrayList<Player>();
		Iterator<Player> it = iterator();
		while(it.hasNext())
		{
			Player p2 = it.next();
			if(!p.equals(p2))
				resultList.add(p2);
		}
		return new Rosters(resultList);
	}

    // RETURNS: true iff the given player is on this roster.
    // EXAMPLES:
    //
    //     Rosters.empty().has(p)  =>  false
    //
    // If r is any roster, then
    //
    //     r.with(p).has(p)     =>  true
    //     r.without(p).has(p)  =>  false

    public boolean has (Player p)
	{
		Iterator<Player> it = this.iterator();
		while(it.hasNext())
		{
			Player p2 = it.next();
			if(p2.equals(p))
				return true;
		}
		return false;
	}

    // RETURNS: the number of players on this roster.
    // EXAMPLES:
    //
    //     Rosters.empty().size()  =>  0
    //
    // If r is a roster with r.size() == n, and r.has(p) is false, then
    //
    //     r.without(p).size()          =>  n
    //     r.with(p).size               =>  n+1
    //     r.with(p).with(p).size       =>  n+1
    //     r.with(p).without(p).size()  =>  n

    public int size ()
	{
		return playerList.size();
	}

    // RETURNS:	the number of players on this roster whose current
    // 			status indicates they are available.

    public int readyCount ()
	{
		int count =0;
		Iterator<Player> it = iterator();
		while(it.hasNext())
		{
			Player p = it.next();
			if(p.available())
				count++;
		}
		return count;
	}

    // RETURNS:	a roster consisting of all players on this roster
    // 			whose current status indicates they are available.

    public Roster readyRoster ()
	{
		List<Player> resultList = new ArrayList<Player>();
		Iterator<Player> it = iterator();
		while(it.hasNext())
		{
			Player p = it.next();
			if(p.available())
				resultList.add(p);
		}
		return new Rosters(resultList);
	}

    // RETURNS:	an iterator that generates each player on this
    //          roster exactly once, in alphabetical order by name.

    public Iterator<Player> iterator ()
	{
		Collections.sort(playerList,(Player p1, Player p2) -> p1.name().compareTo(p2.name()));
		Iterator<Player> it = playerList.iterator();
		return it;
	}
	
	// MAIN METHOD
	
	public static void main(String args[])
	{
		Player a = Players.make("A");
		Player b = Players.make("B");
		Player c = Players.make("C");
		Player d = Players.make("D");
		Player e = Players.make("E");
		Player f = Players.make("F");
		Player a2 = a;
		Roster r1 = empty();
		Roster r2 = r1.with(a).with(d).with(c).with(e).with(b);
		Roster r3 = r1.with(b).with(e).with(c).with(d).with(a);
		assert r2.equals(r3);
		assert r2.equals(r2.with(b));
		assert r2.with(f).equals(r2.with(f).with(f));
		assert !r2.equals(r3.with(f));
		assert r2.toString().equals(r3.toString());
		assert r2.toString() != r3.with(f).toString();
		assert r2.has(b);
		assert !r2.without(b).has(b);
		assert r2.size() - r2.without(a).size() == 1;
		assert r2.readyCount() == 5;
		d.changeInjuryStatus(true);
		assert r2.readyCount() == 4;
		Roster r4 = r2.readyRoster();
		assert r2.without(d).equals(r4);
	}
}

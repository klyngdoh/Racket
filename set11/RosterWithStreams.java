// A RosterWithStream is an object of any class that implements
// the RosterWithStream interface defined below.
//
// A RosterWithStream object represents a set of players.
//
// RosterWithStream objects are immutable, but all players on a
// RosterWithStream have mutable status, which can affect the
// values returned by the readyCount() and readyRoster() methods.
//
// If r is a RosterWithStream object, then
// r.iterator() generates the players of r in alphabetical order
//
// If r1 and r2 are RosterWithStream objects, then r1.equals(r2)
// if and only if
// every player on roster r1 is also on roster r2, and
// every player on roster r2 is also on roster r1.
//
// If r is a roster, then r.hashCode() always returns the same
// value, even if r has some players whose status changes.
//
// If r1 and r2 are rosters of different sizes, then
// r1.toString() is not the same string as r2.toString().
//
// RosterWithStreams.empty() is a static factory method that returns a
// RosterWithStream with no players.

import java.util.*;
import java.util.stream.Stream;

public class RosterWithStreams implements RosterWithStream {

	private Set<Player> playerSet;

	RosterWithStreams(Set<Player> playerSet)
	{
		this.playerSet = playerSet;
	}
	
	public boolean equals(Object o)
	{
		if (o instanceof RosterWithStream)
		{
			RosterWithStream r = (RosterWithStream) o;
			return isEqual(r);
		}
		else 
			return false;
	}	
	
	public boolean isEqual(RosterWithStream r)
	{
		Iterator<Player> it1 = iterator();
		while(it1.hasNext())
		{
			Player p = it1.next();
			if(!r.has(p))
				return false;
		}
		
		Iterator<Player> it2 = r.iterator();
		while(it2.hasNext())
		{
			Player p = it2.next();
			if(!has(p))
				return false;
		}
		return true;
	}
	
	public String toString()
	{
		String str = "";
		Iterator<Player> it = iterator();
		while(it.hasNext())
		{
			Player p = it.next();
			str = str + p.name();
			if(it.hasNext())
				str = str +"\n";
		}
		return str;
	}
	
	public int hashCode()
	{
		return 0;
	}	
	
    // Returns a roster consisting of the given player together
    // with all players on this roster.
    // Example:
    //     r.with(p).with(p)  =>  r.with(p)

    public RosterWithStream with (Player p)
	{
		Set<Player> resultSet = new HashSet<Player>();
		resultSet.addAll(playerSet);
		resultSet.add(p);
		return new RosterWithStreams(resultSet);
	}

    // Returns a roster consisting of all players on this roster
    // except for the given player.
    // Examples:
    //     RosterWithStreams.empty().without(p)  =>  RosterWithStreams.empty()
    //     r.without(p).without(p)     =>  r.without(p)

    public RosterWithStream without (Player p)
	{
		Set<Player> resultSet = new HashSet<Player>();
		resultSet.addAll(playerSet);
		resultSet.remove(p);
		return new RosterWithStreams(resultSet);
	}
	
    // Returns true iff the given player is on this roster.
    // Examples:
    //
    //     RosterWithStreams.empty().has(p)  =>  false
    //
    // If r is any roster, then
    //
    //     r.with(p).has(p)     =>  true
    //     r.without(p).has(p)  =>  false

    public boolean has(Player p)
	{
		return playerSet.contains(p);
	}

    // Returns the number of players on this roster.
    // Examples:
    //
    //     RosterWithStreams.empty().size()  =>  0
    //
    // If r is a roster with r.size() == n, and r.has(p) is false, then
    //
    //     r.without(p).size()          =>  n
    //     r.with(p).size()             =>  n+1
    //     r.with(p).with(p).size()     =>  n+1
    //     r.with(p).without(p).size()  =>  n

    public int size()
	{
		return playerSet.size();
	}

    // Returns the number of players on this roster whose current
    // status indicates they are available.

    public int readyCount()
	{
		int ctr = 0;
		Iterator<Player> it = iterator();
		while(it.hasNext())
		{
			Player p = it.next();
			if(p.available())
				ctr++;
		}
		return ctr;
	}

    // Returns a roster consisting of all players on this roster
    // whose current status indicates they are available.

    public RosterWithStream readyRoster()
	{
		Set<Player> resultSet = new HashSet<Player>();
		Iterator<Player> it = iterator();
		while (it.hasNext())
		{
			Player p = it.next();
			if(p.available())
				resultSet.add(p);
		}
		return new RosterWithStreams(resultSet);
	}

    // Returns an iterator that generates each player on this
    // roster exactly once, in alphabetical order by name.

    public Iterator<Player> iterator()
	{
		List<Player> playerList = new ArrayList<Player>();
		playerList.addAll(playerSet);
		Collections.sort(playerList, (Player p1, Player p2) -> p1.name().compareTo(p2.name()));
		Iterator<Player> it = playerList.iterator();
		return it;
	}
	
	public static RosterWithStreams empty()
	{
		Set<Player> pSet = new HashSet<Player>();
		return new RosterWithStreams(pSet);
	}
	

    // Returns a sequential Stream with this RosterWithStream
    // as its source.
    // The result of this method generates each player on this
    // roster exactly once, in alphabetical order by name.
    // Examples:
    //
    //     RosterWithStreams.empty().stream().count()  =>  0
    //
    //     RosterWithStreams.empty().stream().findFirst().isPresent()
    //         =>  false
    //
    //     RosterWithStreams.empty().with(p).stream().findFirst().get()
    //         =>  p
    //
    //     this.stream().distinct()  =>  true
    //
    //     this.stream().filter((Player p) -> p.available()).count()
    //         =>  this.readyCount()

    public Stream<Player> stream ()
	{
		List<Player> playerList = new ArrayList<Player>();
		playerList.addAll(playerSet);
		Collections.sort(playerList, (Player p1, Player p2) -> p1.name().compareTo(p2.name()));
		return playerList.stream();
	}
	
	public static void main(String args[])
	{
		Player a = Players.make("A");
		Player b = Players.make("B");
		Player c = Players.make("C");
		Player d = Players.make("D");
		Player e = Players.make("E");
		Player f = Players.make("F");
		Player a2 = a;
		RosterWithStream r1 = empty();
		RosterWithStream r2 = r1.with(a).with(d).with(c).with(e).with(b);
		RosterWithStream r3 = r1.with(b).with(e).with(c).with(d).with(a);
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
		RosterWithStream r4 = r2.readyRoster();
		assert r2.without(d).equals(r4);
		//System.out.println("All tests passed");
	}
}

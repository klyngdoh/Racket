import java.util.*;

public class TestRosterWithStream
{
	public static void main(String args[])
	{
		Player a = Players.make("A");
		Player b = Players.make("B");
		Player c = Players.make("C");
		Player d = Players.make("D");
		Player e = Players.make("E");
		Player f = Players.make("F");
		Player g = Players.make("G");
		Player a2 = a;
		RosterWithStream r1 = RosterWithStreams.empty();
		RosterWithStream r2 = r1.with(a).with(d).with(c).with(e).with(b);
		RosterWithStream r3 = r1.with(c).with(g).with(f).with(b);
		
		// Testing allMatch and anyMatch
		
		assert r2.stream().allMatch(p -> p.available());
		assert r2.stream().anyMatch(p -> p.available());
		a.changeContractStatus(false);
		assert !r2.stream().allMatch(p -> p.available());
		assert r2.stream().anyMatch(p -> p.available());
		b.changeInjuryStatus(true);
		c.changeInjuryStatus(true);
		d.changeSuspendedStatus(true);
		e.changeSuspendedStatus(true);
		assert !r2.stream().allMatch(p -> p.available());
		assert !r2.stream().anyMatch(p -> p.available());
		
		// Testing count
		
		assert r1.stream().count() == 0;
		assert r2.stream().count() == 5;
		assert r2.with(f).stream().count() == 6;
		assert r2.without(a).stream().count() == 4;
		
		// testing distinct
		
		assert r2.stream().distinct().count() == r2.with(a).with(a).with(a).with(a).with(a).with(a).stream().distinct().count();
		
		// testing filter
		
		b.changeInjuryStatus(false);
		assert r2.stream().filter(p -> p.available()).count() == 1;
		c.changeInjuryStatus(false);
		assert r2.stream().filter(p -> p.available()).count() == 2;
		
		// testing forEach
		
		r2.stream().forEach((Player p) -> p.changeInjuryStatus(false));
		r2.stream().forEach((Player p) -> p.changeSuspendedStatus(false));
		r2.stream().forEach((Player p) -> p.changeContractStatus(true));
		assert r2.readyCount() == 5;
		
		// testing map
		
		assert r2.stream().map(p->p.isInjured()).filter(p->p).count() == 0;
		b.changeInjuryStatus(true);
		c.changeInjuryStatus(true);
		assert r2.stream().map(p->p.isInjured()).filter(p->p).count() == 2;
		
		// testing reduce
		
		assert (r2.stream().map(p-> p.name()).reduce("",(n1,n2) -> n1 + n2)).equals("ABCDE");		
		assert (r3.stream().map(p-> p.name()).reduce("",(n1,n2) -> n1 + n2)).equals("BCFG");
		
		// testing skip
		
		assert r2.stream().skip(4).count() == 1;
		assert r3.stream().skip(1).count() == 3;
		
		//testing toArray
		
		assert r2.stream().toArray().length == 5;
		assert r2.stream().toArray()[0].equals(a);
		assert r2.stream().toArray()[4].equals(e);
		
		
		System.out.println("All Stream tests passsed.");
	}
}

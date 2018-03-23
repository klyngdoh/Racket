// Constructor template for Competitor1:
//     new Competitor1 (Competitor c1)
//
// Interpretation: the competitor represents an individual or team

// Note:  In Java, you cannot assume a List is mutable, because all
// of the List operations that change the state of a List are optional.
// Mutation of a Java list is allowed only if a precondition or other
// invariant says the list is mutable and you are allowed to change it.

import java.util.List;
import java.util.ArrayList;
import java.util.Collections;

// You may import other interfaces and classes here.

class Competitor1 implements Competitor {

    private String s;

    Competitor1 (String s) {

        this.s = s;

    }

    // returns the name of this competitor

    public String name () {

        return s;

    }

    // GIVEN: another competitor and a list of outcomes
    // RETURNS: true iff one or more of the outcomes indicates this
    //     competitor has defeated or tied the given competitor

    public boolean hasDefeated (Competitor c2, List<Outcome> outcomes) {

        for(Outcome oc : outcomes)
		{
			if(hasDefeatedHelper(s, c2.name(), oc))
				return true;
		}
		return false;
    }
	
	// GIVEN: The names of two competitors and an outcomes
	// RETURNS: true iff that outcome indicates that the first competitor has 
	//          defeated or tied the second
	
	private boolean hasDefeatedHelper (String s1, String s2, Outcome oc)
	{
		if((oc.isTie() && 	((s1.equals(oc.first().name()) && 
							 s2.equals(oc.second().name())) ||
							(s1.equals(oc.second().name()) && 
							 s2.equals(oc.first().name())))) ||
			(!oc.isTie() && (s1.equals(oc.winner().name()) && 
							 s2.equals(oc.loser().name()))))
			return true;
		else
			return false;
	}

    // GIVEN: a list of outcomes
    // RETURNS: a list of the names of all competitors mentioned by
    //     the outcomes that are outranked by this competitor,
    //     without duplicates, in alphabetical order

    public List<String> outranks (List<Outcome> outcomes) {

        List<String> found = new ArrayList<String>();
		for(Outcome oc: outcomes)
		{
			if(!getLoser(oc,s).equals(""))
				found.add(getLoser(oc,s));
		}
		return normalize(outrankHelper(outcomes,found));
    }
	
	// GIVEN: a list of outcomes and a list of competitors' names
	// WHERE: found is the list of names that this competitor outranks so far
	// RETURNS: a list of all the competitors that are outranked by all the  
	//          competitors in found
	
	public List<String> outrankHelper (List<Outcome> outcomes, List<String> found)
	{
		List<String> temp = new ArrayList<String>();
		List<String> temp2 = new ArrayList<String>();
		temp.addAll(found);
		temp.add(s);
		if(listEqual(found,outrankList(outcomes,temp)))
			return found;
		else
		{	
			temp2.addAll(outrankList(outcomes,temp));
			temp2.addAll(found);
			return outrankHelper(outcomes,normalize(temp2));
		}
	}

	// GIVEN: a list of outcomes and a list of names of competitors
	// RETURNS: the combined list of all the names of competitors each 
	//          competitor in the list outranks
	
	public List<String> outrankList (List<Outcome> outcomes, List<String> names)
	{
		List<String> allOutranks = new ArrayList<String>();
		for(String str: names)
		{
			for(Outcome oc: outcomes)
			{
				if(!getLoser(oc,str).equals(""))
					allOutranks.add(getLoser(oc,str));
			}
		}			
		return normalize(allOutranks);
	}
	
	// GIVEN: the name of a competitor and an outcome
	// RETURNS: the name of the other competitor if this competitor won
	
	public String getLoser (Outcome oc,String str)
	{
		if(oc.isTie())
		{
			if(str.equals(oc.first().name()))
				return oc.second().name();
			else if(str.equals(oc.second().name()))
				return oc.first().name();
			else
				return "";
		}
		else
		{	if(str.equals(oc.winner().name()))
				return oc.loser().name();
			else
				return "";
		}
	}

    // GIVEN: a list of outcomes
    // RETURNS: a list of the names of all competitors mentioned by
    //     the outcomes that outrank this competitor,
    //     without duplicates, in alphabetical order

    public List<String> outrankedBy (List<Outcome> outcomes) {

        List<String> found = new ArrayList<String>();
		for(Outcome oc: outcomes)
		{
			if(!getWinner(oc,s).equals(""))
				found.add(getWinner(oc,s));
		}
		return normalize(outrankedByHelper(outcomes,found));

    }
	
	// GIVEN: a list of outcomes and a list of names of competitors
	// WHERE: found is the list of competitors that are outrank this competitor
	//        so far
	// RETURNS: a list of all the competitors that outrank this competitor
	
	public List<String> outrankedByHelper (List<Outcome> outcomes, List<String> found)
	{
		List<String> temp = new ArrayList<String>();
		List<String> temp2 = new ArrayList<String>();
		temp.addAll(found);
		temp.add(s);
		if(listEqual(found,outrankedByList(outcomes,temp)))
			return found;
		else
		{	
			temp2.addAll(outrankedByList(outcomes,temp));
			temp2.addAll(found);
			return outrankedByHelper(outcomes,normalize(temp2));
		}
	}
	
	// GIVEN: a list of outcomes and a list of the names of competitors
	// RETURNS: the combined list of names of competitors all the competitors 
	//          are outranked by
	
	public List<String> outrankedByList (List<Outcome> outcomes, List<String> names)
	{
		List<String> allOutranks = new ArrayList<String>();
		for(String str: names)
		{
			for(Outcome oc: outcomes)
			{
				if(!getWinner(oc,str).equals(""))
					allOutranks.add(getWinner(oc,str));
			}
		}			
		return normalize(allOutranks);
	}
	
	// GIVEN: an outcome and the name of a competitor
	// RETURNS: the name of the winner of the outcome if this competitor lost	
	
	public String getWinner (Outcome oc,String str)
	{
		if(oc.isTie())
		{
			if(str.equals(oc.first().name()))
				return oc.second().name();
			else if(str.equals(oc.second().name()))
				return oc.first().name();
			else
				return "";
		}
		else
		{	if(str.equals(oc.loser().name()))
				return oc.winner().name();
			else
				return "";
		}
	}

    // GIVEN: a list of outcomes
    // RETURNS: a list of the names of all competitors mentioned by
    //     one or more of the outcomes, without repetitions, with
    //     the name of competitor A coming before the name of
    //     competitor B in the list if and only if the power-ranking
    //     of A is higher than the power ranking of B.

    public List<String> powerRanking (List<Outcome> outcomes) {

		List<String> result = new ArrayList<String>();
        for(Competitor comp: mergeSortPower(getCompetitorList(outcomes), outcomes))
		{
			result.add(comp.name());
		}
		return result;
    }
	
	// GIVEN: a list of outcomes
	// RETURNS: a list of all competitors who participated in the outcomes
	
	public List<Competitor> getCompetitorList(List<Outcome> outcomes)
	{
		List<Competitor> compList = new ArrayList<Competitor>();
		for(Outcome oc: outcomes)
		{
			compList.add(oc.first());
			compList.add(oc.second());
		}
		return removeDuplicatesCompetitor(compList);
	}
	
	// GIVEN: two competitors and a list of outcomes
	// RETURNS: true iff the first competitor has a higher rank than the second
	
	public boolean higherRank(Competitor p1, Competitor p2, List<Outcome> outcomes)
	{
		if(p1.outrankedBy(outcomes).size() < p2.outrankedBy(outcomes).size())
			return true;
		else if (p1.outrankedBy(outcomes).size() > p2.outrankedBy(outcomes).size())
			return false;
		else if (p1.outranks(outcomes).size() > p2.outranks(outcomes).size())
			return true;
		else if (p1.outranks(outcomes).size() < p2.outranks(outcomes).size())
			return false;
		else if (getPercentage(p1.name(),outcomes) > getPercentage(p2.name(),outcomes))
			return true;
		else if (getPercentage(p1.name(),outcomes) < getPercentage(p2.name(),outcomes))
			return false;
		else if (p1.name().compareTo(p2.name()) < 0)
			return true;
		else
			return false;
	}
	
	// GIVEN: A string and a list of outcomes
	// RETURNS: the number of non-losing outcomes the competitor with that name participated in
	
	public int nonLoss(String p1, List<Outcome> outcomes)
	{
		int ctr = 0;
		for(Outcome oc:outcomes)
		{
			if(p1.equals(oc.first().name()) || (oc.isTie() && p1.equals(oc.second().name())))
				ctr++;					
		}
		return ctr;
	}
	
	// GIVEN: A string and a list of outcomes
	// RETURNS: the number of outcomes the competitor with that name participated in.
	
	public int totalParticipation(String p1, List<Outcome> outcomes)
	{
		int ctr = 0;
		for(Outcome oc:outcomes)
		{
			if(p1.equals(oc.first().name()) || p1.equals(oc.second().name()))
				ctr++;
		}
		return ctr;
	}
	
	// GIVEN: A string and a list of outcomes
	// RETURNS: the non-losing percentage of the competitor with that name
	
	public double getPercentage(String p1, List<Outcome> outcomes)
	{
		return (double)(nonLoss(p1,outcomes))/totalParticipation(p1,outcomes);
	}
	
	// GIVEN: A list of competitors and a list of outcomes
	// RETURNS: A similar list of competitors sorted in order of power ranking
	
	public List<Competitor> mergeSortPower(List<Competitor> complist, List<Outcome> outcomes)
	{
		List<Competitor> left = new ArrayList<Competitor>();
		List<Competitor> right = new ArrayList<Competitor>();
		if(complist.size() == 0 || complist.size() == 1)
			return complist;
		else
		{	
			for(int i=0;i<complist.size();i++)
			{
				if(i<complist.size()/2)
					left.add(complist.get(i));
				else
					right.add(complist.get(i));
			}
			return mergePower(mergeSortPower(left,outcomes), mergeSortPower(right,outcomes), outcomes);
		}
	}
	
	// GIVEN: two lists of competitors and a list of outcomes
	// RETURNS: a list of competitors that contains all the elements of the two 
	//          given lists, in order of power ranking
	
	public List<Competitor> mergePower(List<Competitor> left, List<Competitor> right, List<Outcome> outcomes)
	{
		List<Competitor> result=new ArrayList<Competitor>();
		if(left.size() == 0)
			return right;
		else if(right.size() == 0)
			return left;
		else if(higherRank(left.get(0),right.get(0),outcomes))
		{	
			result.add(left.get(0));
			left.remove(0);
			result.addAll(mergePower(left,right,outcomes));
			return result;
		}
		else
		{
			result.add(right.get(0));
			right.remove(0);
			result.addAll(mergePower(left,right,outcomes));
			return result;
		}
	}
	
	// GIVEN: a list of strings
	// RETURNS: a similar list of strings with no duplicates and in alphabetical order
	
	public List<String> normalize(List <String> strlist)
	{
		Collections.sort(strlist);
		return removeDuplicates(strlist);
	}
	
	// GIVEN: a list of strings
	// RETURNS: a similar list of strings but with no duplicates
	
	public List<String> removeDuplicates (List<String> strlist)
	{
		List<String> list2 = new ArrayList<String>();
		for(String str: strlist)
			if(!list2.contains(str))
				list2.add(str);
		return list2;		
	}
	
	// GIVEN: a list of competitors
	// RETURNS: a similar list of strings but with no duplicates
	
	public List<Competitor> removeDuplicatesCompetitor (List<Competitor> complist)
	{
		List<Competitor> list2 = new ArrayList<Competitor>();
		for(Competitor comp: complist)
			if(!list2.contains(comp))
				list2.add(comp);
		return list2;		
	}
	
	// GIVEN: two lists of strings
	// RETURNS: true iff they contain the same elements
	
	public boolean listEqual (List<String> strlist1, List<String> strlist2)
	{
		if(strlist1.size() != strlist2.size())
			return false;
		for(int i=0;i<strlist1.size();i++)
			if(!strlist1.get(i).equals(strlist2.get(i)))
				return false;
		return true;
	}
	
	public static void main(String[] args)
	{
		Competitor1 a = new Competitor1("A");
		Competitor1 b = new Competitor1("B");
		Competitor1 c = new Competitor1("C");
		Competitor1 d = new Competitor1("D");
		Competitor1 e = new Competitor1("E");
		Competitor1 f = new Competitor1("F");
		Competitor1 g = new Competitor1("G");
		Competitor1 h = new Competitor1("H");
		Competitor1 i = new Competitor1("I");
		Competitor1 j = new Competitor1("J");
		
		List<Outcome> testCase1 = new ArrayList<Outcome>();
		testCase1.add(new Defeat1(a,d));
		testCase1.add(new Defeat1(a,e));
		testCase1.add(new Defeat1(c,b));
		testCase1.add(new Defeat1(c,f));
		testCase1.add(new Tie1(d,b));
		testCase1.add(new Defeat1(f,e));
		
		List<String> testAnswer1 = new ArrayList<String>();
		testAnswer1.add("C");
		testAnswer1.add("A");
		testAnswer1.add("F");
		testAnswer1.add("E");
		testAnswer1.add("B");
		testAnswer1.add("D");
		assert a.listEqual(a.powerRanking(testCase1),testAnswer1);
		
		testCase1.add(new Defeat1(a,b));
		testAnswer1.remove(4);
		testAnswer1.add("B");
		assert a.listEqual(a.powerRanking(testCase1),testAnswer1);
		
		List<Outcome> testCase2 = new ArrayList<Outcome>();
		List<String> testAnswer2 = new ArrayList<String>();
		
		testCase2.add(new Defeat1(e,f));
		testCase2.add(new Tie1(a,b));
		testCase2.add(new Defeat1(c,f));
		testCase2.add(new Defeat1(b,d));
		testCase2.add(new Tie1(a,e));
		testCase2.add(new Defeat1(a,f));
		
		testAnswer2.add("C");
		testAnswer2.add("A");
		testAnswer2.add("B");
		testAnswer2.add("E");
		testAnswer2.add("D");
		testAnswer2.add("F");
		assert a.listEqual(a.powerRanking(testCase2),testAnswer2);
		
		List<Outcome> testCase3 = new ArrayList<Outcome>();
		List<String> testAnswer3 = new ArrayList<String>();
		
		testCase3.add(new Tie1(a,b));
		testCase3.add(new Defeat1(j,d));
		testCase3.add(new Tie1(b,e));
		testCase3.add(new Defeat1(a,f));
		testCase3.add(new Defeat1(g,d));
		testCase3.add(new Tie1(c,b));
		testCase3.add(new Defeat1(h,d));
		testCase3.add(new Tie1(i,j));
		testCase3.add(new Defeat1(c,d));
		testCase3.add(new Tie1(a,g));
		testCase3.add(new Defeat1(h,b));
		
		testAnswer3.add("H");
		testAnswer3.add("I");
		testAnswer3.add("J");
		testAnswer3.add("A");
		testAnswer3.add("C");
		testAnswer3.add("E");
		testAnswer3.add("G");
		testAnswer3.add("B");
		testAnswer3.add("F");
		testAnswer3.add("D");
		
		assert a.listEqual(a.powerRanking(testCase3),testAnswer3);
		
		assert(a.hasDefeated(b,testCase3));
		assert(b.hasDefeated(e,testCase3));
		assert(!d.hasDefeated(h,testCase3));
	}
}

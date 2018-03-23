// Constructor template for Tie1:
//     new Tie1 (Competitor c1, Competitor c2)
// Interpretation:
//     c1 and c2 have engaged in a contest that ended in a tie

public class Tie1 implements Outcome {

    private Competitor c1;
	private Competitor c2;

    Tie1 (Competitor c1, Competitor c2) {

        this.c1 = c1;
		this.c2 = c2;

    }

    // RETURNS: true iff this outcome represents a tie

    public boolean isTie () {

        return true;

    }

    // RETURNS: one of the competitors

    public Competitor first () {

        return c1;

    }

    // RETURNS: the other competitor

    public Competitor second () {

        return c2;

    }

    // GIVEN: no arguments
    // WHERE: this.isTie() is false
    // RETURNS: the winner of this outcome

    public Competitor winner () {

        return c1;

    }

    // GIVEN: no arguments
    // WHERE: this.isTie() is false
    // RETURNS: the loser of this outcome

    public Competitor loser () {

        return c2;

    }
	
	public static void main(String[] args)
	{
		Competitor1 steve = new Competitor1("Steve");
		Competitor1 adam = new Competitor1("Adam");
		Tie1 t = new Tie1(steve,adam);
		assert t.isTie() == true;
		assert t.first().name() == "Steve";
		assert t.second().name() == "Adam";
		if(!t.isTie())
		{
			assert t.winner().name() == "Steve";
			assert t.loser().name() == "Adam";
		}
	}
}

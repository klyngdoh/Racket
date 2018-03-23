// Constructor template for Players:
//     new Players (String name)
// Interpretation:
//     name is the name of the player in the league have engaged in a contest that ended in a tie

public class Players implements Player {

    private String playerName;
	private boolean contract;
	private boolean injured;
	private boolean suspended;

	private static final boolean DEFAULT_CONTRACT = true;
	private static final boolean DEFAULT_INJURY = false;
	private static final boolean DEFAULT_SUSPENDED = false;	
	
    Players (String playerName, boolean contract, boolean injured, boolean suspended) {

        this.playerName = playerName;
		this.contract = contract;
		this.injured = injured;
		this.suspended = suspended;
		
    }
	
	// GIVEN: An object
	// RETURNS: true iff it is the same player
	
	public boolean equals(Object o)
	{
		if (o instanceof Player)
		{
			Player p2 = (Player) o;
			return isEqual(p2);
		}
		else
			return false;
		
	}
	
	// RETURNS: the hash code - the sum of the ascii values of all the characters in the player's name
	
	public int hashCode()
	{
		char[] name = playerName.toCharArray();
		int sum = 0;
		for(int i = 0; i<name.length; i++)
			sum+= (int)name[i];
		return sum;
	}
	
	// RETURNS: the player's name
	
	public String toString()
	{
		return name();
	}
	
	// GIVEN: A player
	// RETURNS: true iff the given player is the same as the current one
	
	private boolean isEqual (Player p2)
	{
		return this == p2;
	}
	
	// RETURNS: The name of this player
	
	public String name()
	{
		return playerName;
	}

	// RETURNS: true iff this player is under contract, not injured and not suspended
	
    public boolean available () {

        return contract && !injured && !suspended;

    }
	
	// RETURNS: true iff this player is under contract
	
	public boolean underContract()
	{
		return contract;
	}
	
	// RETURNS: true iff this player is injured
	
	public boolean isInjured()
	{
		return injured;
	}
	
	// RETUNRS: true iff this player is suspended
	
	public boolean isSuspended()
	{	
		return suspended;
	}
	
	// Changes this player's underContract() status to the specified boolean
	
	public void changeContractStatus(boolean newStatus)
	{
		contract = newStatus;
	}
	
	// Changes this player's isInjured() status to the specified boolean
	
	public void changeInjuryStatus(boolean newStatus)
	{
		injured = newStatus;
	}
	
	// Changes this player's isSuspended() status to the specified boolean
	
	public void changeSuspendedStatus(boolean newStatus)
	{
		suspended = newStatus;
	}
	
	// GIVEN: A string
	// RETURNS: a player whose name is the given string and is initially available
	
	public static Players make(String name)
	{
		return new Players(name, DEFAULT_CONTRACT, DEFAULT_INJURY, DEFAULT_SUSPENDED);
	}
	
	// MAIN function
	
	public static void main(String args[])
	{
		Players steve = make("Steve");
		Players steve2 = steve;
		Players steve3 = make("Steve");
		assert steve.available();
		assert steve.name() == "Steve";
		assert !steve.isSuspended();
		assert !steve.isInjured();
		assert steve.underContract();
		assert steve.equals(steve2);
		assert !steve.equals(steve3);
		assert steve.hashCode() == 519;
		assert steve.toString() == steve3.toString();
		steve.changeContractStatus(false);
		steve.changeInjuryStatus(true);
		steve.changeSuspendedStatus(true);
		assert steve.isSuspended();
		assert steve.isInjured();
		assert !steve.underContract();
		System.out.println("All Players tests passed");
	}
}

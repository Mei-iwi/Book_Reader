namespace BookReader.Api.DTOs.Membership;

public class MembershipPackageDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int DurationDays { get; set; }
    public string? Description { get; set; }
    public bool IsActive { get; set; }
}

public class UserMembershipDto
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int MembershipPackageId { get; set; }
    public string PackageName { get; set; } = string.Empty;
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public string Status { get; set; } = string.Empty;
}

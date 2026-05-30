using System;
using System.Collections.Generic;

namespace BookReader.Api.Entities;

public partial class MembershipPackage
{
    public int Id { get; set; }

    public string Name { get; set; } = null!;

    public decimal Price { get; set; }

    public int DurationDays { get; set; }

    public string? Description { get; set; }

    public bool IsActive { get; set; }

    public virtual ICollection<UserMembership> UserMemberships { get; set; } = new List<UserMembership>();
}

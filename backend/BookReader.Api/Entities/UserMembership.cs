using System;
using System.Collections.Generic;

namespace BookReader.Api.Entities;

public partial class UserMembership
{
    public int Id { get; set; }

    public int UserId { get; set; }

    public int MembershipPackageId { get; set; }

    public DateTime StartDate { get; set; }

    public DateTime EndDate { get; set; }

    public string Status { get; set; } = null!;

    public virtual MembershipPackage MembershipPackage { get; set; } = null!;

    public virtual AppUser User { get; set; } = null!;
}

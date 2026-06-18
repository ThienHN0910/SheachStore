namespace SheachStore.WebApi.Models;

public class Category
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Slug { get; set; } = string.Empty;

    public ICollection<Book> Books { get; set; } = new List<Book>();
}

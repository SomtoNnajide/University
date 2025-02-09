using Final_Project.Data;
using Final_Project.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.ComponentModel.Design;
using System.Diagnostics;
using IHostingEnvironment = Microsoft.AspNetCore.Hosting.IWebHostEnvironment;

namespace Final_Project.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;
        private readonly ApplicationDbContext _context;
        private readonly IHostingEnvironment _hostingEnv;

        public HomeController(ILogger<HomeController> logger, ApplicationDbContext context, IHostingEnvironment hostingEnv)
        {
            _logger = logger;
            _context = context;
            _hostingEnv = hostingEnv;
        }

        public async Task<IActionResult> Index()
        {
            if (TempData["user"] != User.Identity.Name)
            {
                TempData.Clear();
            }

            TempData["user"] = User.Identity.Name;

            return _context.GenAI != null ?
                View(await _context.GenAI.ToListAsync()) :
                Problem("Entity set 'ApplicationDbContext.GenAI' is null.");
        }

        public IActionResult Contact()
        {
            return View();
        }

        public IActionResult Jobs()
        {
            return View();
        }

        public IActionResult GenAI()
        {
            return View();
        }

        public async Task<IActionResult> GenAISites()
        {
            return _context.GenAI != null ?
            View(await _context.GenAI.ToListAsync()) :
            Problem("Entity set 'ApplicationDbContext.GenAI'  is null.");
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}
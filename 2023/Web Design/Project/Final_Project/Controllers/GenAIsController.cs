using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using Final_Project.Data;
using Final_Project.Models;
using IHostingEnvironment = Microsoft.AspNetCore.Hosting.IWebHostEnvironment;
using Microsoft.AspNetCore.Authorization;
using System.Diagnostics;
using Microsoft.AspNetCore.Authorization.Infrastructure;
using Microsoft.CodeAnalysis.CSharp.Syntax;

namespace Final_Project.Controllers
{
    public class GenAIsController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly IHostingEnvironment _hostingEnv;

        public GenAIsController(ApplicationDbContext context, IWebHostEnvironment hostingEnv)
        {
            _context = context;
            _hostingEnv = hostingEnv;
        }

        // GET: GenAIs
        public async Task<IActionResult> Index()
        {
              return _context.GenAI != null ? 
                          View(await _context.GenAI.ToListAsync()) :
                          Problem("Entity set 'ApplicationDbContext.GenAI'  is null.");
        }

        // GET: GenAIs/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null || _context.GenAI == null)
            {
                return NotFound();
            }

            var genAI = await _context.GenAI
                .FirstOrDefaultAsync(m => m.Id == id);
            if (genAI == null)
            {
                return NotFound();
            }

            return View(genAI);
        }

        // GET: GenAIs/Create
        [Authorize]
        public IActionResult Create()
        {
            return View();
        }

        // POST: GenAIs/Create
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize]
        public async Task<IActionResult> Create([Bind("Id,GenAIName,Summary,ImageFilename,AnchorLink,Like")] GenAI genAI, 
            UploadFile uploadFile)
        {
            if (uploadFile.File != null)
            {
                var fileName = Path.GetFileName(uploadFile.File.FileName);

                genAI.ImageFilename = fileName;
                genAI.AnchorLink = genAI.Id.ToString();

                var filePath = Path.Combine(_hostingEnv.WebRootPath, "images", fileName);

                using (var fileStream = new FileStream(filePath, FileMode.Create))
                {
                    await uploadFile.File.CopyToAsync(fileStream);
                }
            }
            else if (uploadFile.File == null)
            {
                genAI.AnchorLink = "";
                genAI.ImageFilename = "";
                TempData["ErrorMessage"] = "Please fill in all required fields.";
                return RedirectToAction("Create", "GenAIs");
            }

            if (genAI.GenAIName != null || genAI.Summary != null || uploadFile.File != null)
            {
                _context.Add(genAI);
                await _context.SaveChangesAsync();
                return RedirectToAction("Index", "Home", new { scrollToSection = "gen-ai-blocks" });
            }
            
            return View(genAI);
        }

        // GET: GenAIs/Edit/5
        [Authorize(Roles="admin")]
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null || _context.GenAI == null)
            {
                return NotFound();
            }

            var genAI = await _context.GenAI.FindAsync(id);

            if (genAI == null)
            {
                return NotFound();
            }
            return View(genAI);
        }

        // POST: GenAIs/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = "admin")]
        public async Task<IActionResult> Edit(int id, [Bind("Id,GenAIName,Summary,ImageFilename,AnchorLink,Like")] GenAI genAI,
            UploadFile uploadFile)
        {
            if (id != genAI.Id)
            {
                return NotFound();
            }

            if (uploadFile.File != null)
            {
                var fileName = Path.GetFileName(uploadFile.File.FileName);

                genAI.ImageFilename = fileName;
                genAI.AnchorLink = genAI.Id.ToString();

                var filePath = Path.Combine(_hostingEnv.WebRootPath, "images", fileName);

                using (var fileStream = new FileStream(filePath, FileMode.Create))
                {
                    await uploadFile.File.CopyToAsync(fileStream);
                }
            }

            if (genAI.GenAIName != null || genAI.Summary != null) 
            {
                try
                {
                    // Query the database to get the existing GenAI entity
                    var existingGenAI = _context.GenAI.Find(id);

                    if (existingGenAI != null)
                    {
                        // Update the properties of the existing entity
                        existingGenAI.GenAIName = genAI.GenAIName;
                        existingGenAI.Summary = genAI.Summary;

                        // Save the changes to the existing entity
                        _context.Update(existingGenAI);
                        await _context.SaveChangesAsync();

                        genAI.ImageFilename = existingGenAI.ImageFilename;
                        genAI.AnchorLink = existingGenAI.AnchorLink;
                    }
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!GenAIExists(genAI.Id))
                    {
                        return NotFound();
                    }
                    else
                    {
                        throw;
                    }
                }
                return RedirectToAction("GenAISites", "Home", new { scrollToBlock = genAI.Id.ToString() });
            }
            return View(genAI);
        }

        // GET: GenAIs/Delete/5
        [Authorize(Roles = "admin")]
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null || _context.GenAI == null)
            {
                return NotFound();
            }

            var genAI = await _context.GenAI
                .FirstOrDefaultAsync(m => m.Id == id);
            if (genAI == null)
            {
                return NotFound();
            }

            return View(genAI);
        }

        // POST: GenAIs/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = "admin")]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            if (_context.GenAI == null)
            {
                return Problem("Entity set 'ApplicationDbContext.GenAI'  is null.");
            }
            var genAI = await _context.GenAI.FindAsync(id);
            if (genAI != null)
            {
                _context.GenAI.Remove(genAI);
            }
            
            await _context.SaveChangesAsync();
            return RedirectToAction("GenAISites", "Home");
        }

        private bool GenAIExists(int id)
        {
          return (_context.GenAI?.Any(e => e.Id == id)).GetValueOrDefault();
        }

        public async Task<IActionResult> IncreaseLike(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var genAI = await _context.GenAI.FindAsync(id);

            if (genAI == null)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    if (TempData.ContainsKey("like") && TempData.ContainsKey(id.ToString()))
                    {
                        return RedirectToAction("GenAISites", "Home", new { scrollToBlock = genAI.Id.ToString() });
                    }
                    else
                    {
                        TempData[id.ToString()] = id;
                        TempData["like"] = "yes";

                        genAI.Like++;

                        _context.Update(genAI);
                        await _context.SaveChangesAsync();
                    }
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!GenAIExists(genAI.Id))
                    {
                        return NotFound();
                    }
                    else
                    {
                        throw;
                    }
                }
                return RedirectToAction("GenAISites", "Home", new { scrollToBlock = genAI.Id.ToString() });
            }
            return RedirectToAction("GenAISites", "Home", new { scrollToBlock = genAI.Id.ToString() });
        }
    }
}

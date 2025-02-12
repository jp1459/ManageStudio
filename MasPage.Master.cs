﻿using Microsoft.Ajax.Utilities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace AdakStudio
{
    public partial class MasPage : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (LoginedUser.Id <= 0)
            {
                Response.Redirect("Logout.aspx");
            }
        }
        protected string GetProducts()
        {
            string htmls = "";
            var groups = AdakDB.Db.usp_ProductGroup_Select_Active().ToList();
            groups = groups ?? new List<Bank.usp_ProductGroup_Select_ActiveResult>();
            var products = AdakDB.Db.usp_Product_Select_for_Set_Factor().ToList();
            products = products ?? new List<Bank.usp_Product_Select_for_Set_FactorResult>();
            foreach (var g in groups)
            {
                htmls += @"<button class='button' onclick='toggleChildButtons(this)'>" + g.PG_Title + @"</button>";
                var pro = products.Where(a => a.Pro_GroupId == g.PG_ID).OrderBy(a => a.Pro_Priority).ToList();
                pro = pro ?? new List<Bank.usp_Product_Select_for_Set_FactorResult>();
                htmls += @"<div class='child-buttons'>";
                for (int i = 0; i < pro.Count; i++)
                {
                    htmls += @"<button class='child-button' onclick='addItem(" + pro[i].Pro_ID + @"," + pro[i].SalePrice + @",""" + pro[i].Pro_Title + @""",""" + g.PG_Title + @""")'>" + pro[i].Pro_Title + @"</button>";
                }
                htmls += "</div>";
                //string groupId = "PG_" + g.PG_ID;
                //htmls += @"<div class='group'>";
                //htmls += @"<button onclick='toggleGroupItems(" + groupId + @")'>" + g.PG_Title + @"</button>";
                //htmls += @"<ul name='ProductGroups' id='" + groupId + @"' style='display:none;'>";
                //var pro = products.Where(a => a.Pro_GroupId == g.PG_ID).ToList();
                //pro = pro ?? new List<Bank.usp_Product_Select_for_Set_FactorResult>();
                //for (int i = 0; i < pro.Count; i++)
                //{
                //    htmls += @"<li>" + pro[i].Pro_Title + @"
                //                    <button onclick='addItem(" + pro[i].Pro_ID + @"," + pro[i].SalePrice + @",""" + pro[i].Pro_Title + @""")'>افزودن</button>
                //               </li>";
                //}
                //htmls += "</ul></div>";
            }
            return htmls;
        }
        protected string GetCustomer()
        {
            string htmls = "";
            int? outcount = 0;
            var family = AdakDB.Db.usp_Family_Select_For_Grid(null, 1, 1001, ref outcount, 1).ToList();
            family = family ?? new List<Bank.usp_Family_Select_For_GridResult>();
            var orderlist = family.OrderByDescending(a => a.F_Id).ToList();
            foreach (var item in orderlist)
            {
                htmls += "<option value='" + item.F_Id.ToCodeNumber() + "'>" + item.F_Title + "</option>";
            }
            return htmls;
        }
    }
}
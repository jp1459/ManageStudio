﻿<%@ Page Title="" Language="C#" MasterPageFile="~/MasPage.Master" AutoEventWireup="true" CodeFile="Personnel.aspx.cs" Inherits="AdakStudio.Personnel" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Head" runat="server">

    <style>
        .filter-bar {
            display: flex;
            justify-content: space-between;
            margin-bottom: 15px;
        }

            .filter-bar input {
                flex: 1;
                padding: 8px;
                border: 1px solid #ccc;
                border-radius: 5px;
                font-size: 14px;
                margin-right: 10px;
            }

            .filter-bar button {
                padding: 8px 12px;
                background-color: #007bff;
                color: white;
                border: none;
                border-radius: 5px;
                cursor: pointer;
                font-size: 14px;
            }

                .filter-bar button:hover {
                    background-color: #0056b3;
                }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 15px;
        }

            table th, table td {
                padding: 10px;
                text-align: center;
                border: 1px solid #dddddd;
            }

            table th {
                background-color: #f4f4f4;
                color: #333;
            }

            table tr:nth-child(even) {
                background-color: #f9f9f9;
            }

            table tr:hover {
                background-color: #f1f1f1;
            }

        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 10px;
        }

            .pagination button {
                padding: 8px 12px;
                border: 1px solid #ddd;
                background-color: #fff;
                border-radius: 5px;
                cursor: pointer;
                font-size: 14px;
            }

                .pagination button:hover {
                    background-color: #f4f4f4;
                }

                .pagination button:disabled {
                    background-color: #e0e0e0;
                    cursor: not-allowed;
                }

            .pagination span {
                font-size: 14px;
                color: #555;
            }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="post d-flex flex-column-fluid" id="kt_post">
        <div id="kt_content_container" class="container-xxl">
            <div class="card">
                <div class="card-body pt-0">
                    <div class="container">
                        <div class="container mt-5">
                            <div class="row mb-3">
                                <div class="col-md-4">
                                    <input type="text" id="filterInput" class="form-control" placeholder="جستجو...">
                                </div>
                                <div class="col-md-2">
                                    <button id="filterBtn" class="btn btn-bg-warning w-100">اعمال فیلتر</button>
                                </div>
                                <div class="col-md-4">
                                </div>
                                <div class="col-md-2">
                                    <button class="btn btn-primary me-2  open-modal-btn" onclick="ResetFeilds()" data-bs-toggle="modal" data-bs-target="#kt_modal_add_personnel">افزودن پرسنل</button>
                                </div>

                            </div>

                            <table class="table table-striped table-hover table-bordered">
                                <thead class="table-primary">
                                    <tr>
                                        <th data-priority="1">سمت</th>
                                        <th class="min-w-150px">نام و نام خانوادگی</th>
                                        <th class="min-w-150px">شماره همراه</th>
                                        <th class="min-w-150px">نام کاربری</th>
                                        <th class="min-w-70px">وضعیت</th>
                                        <th class="min-w-110px">عملیات</th>
                                    </tr>
                                </thead>
                                <tbody id="dt_Personnels">
                                    <!-- داده‌ها به صورت داینامیک اضافه می‌شوند -->
                                </tbody>
                            </table>

                            <div class="d-flex justify-content-between align-items-center">
                                <button id="prevPageBtn" class="btn btn-secondary">صفحه قبل</button>
                                <span>صفحه فعلی: <span id="currentPage" class="fw-bold">1</span></span>
                                <span>تعداد کل رکوردها: <span id="countAllTable" class="fw-bold">0</span></span>
                                <span>
                                    <select data-control="select" class="form-select" id="s_pageSize" onchange="loadTableDataPersonnel()">
                                        <%Response.Write(PublicMethod.Pagination()); %>
                                    </select>
                                </span>
                                <button id="nextPageBtn" class="btn btn-secondary">صفحه بعد</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="modal fade" id="kt_modal_add_personnel" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered mw-650px">
            <div class="modal-content">
                <div class="modal-header" id="kt_modal_add_customer_header">
                    <h2 class="fw-bolder" id="header_AddPersonnel">افزون اطلاعات</h2>
                    <div id="btn_close" class="btn btn-icon btn-sm btn-active-icon-primary">
                        <span class="svg-icon svg-icon-1">
                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
                                <rect opacity="0.5" x="6" y="17.3137" width="16" height="2" rx="1" transform="rotate(-45 6 17.3137)" fill="black" />
                                <rect x="7.41422" y="6" width="16" height="2" rx="1" transform="rotate(45 7.41422 6)" fill="black" />
                            </svg>
                        </span>
                    </div>
                </div>
                <div class="modal-body py-10 px-lg-17">
                    <div class="scroll-y me-n7 pe-7" id="kt_modal_add_customer_scroll" data-kt-scroll="true" data-kt-scroll-activate="{default: false, lg: true}" data-kt-scroll-max-height="auto" data-kt-scroll-dependencies="#kt_modal_add_customer_header" data-kt-scroll-wrappers="#kt_modal_add_customer_scroll" data-kt-scroll-offset="300px">
                        <div class="d-flex flex-column mb-7 fv-row">
                            <label class="fs-6 fw-bold mb-2">
                                <span class="required">نقش کاربر</span>
                            </label>
                            <select id="p_role" data-dropdown-parent="#kt_modal_add_personnel" data-control="select2" class="form-select form-select-solid select2-hidden-accessible">
                                <%Response.Write(PublicMethod.GetRols()); %>
                            </select>
                        </div>
                        <div class="row g-9 mb-7">
                            <div class="col-md-6 fv-row">
                                <input id="p_firstname" maxlength="20" class="form-control form-control-solid" placeholder="نام" name="firstname" value="" />
                            </div>
                            <div class="col-md-6 fv-row">
                                <input id="p_lastname" maxlength="30" class="form-control form-control-solid" placeholder="نام خانوادگی" name="lastname" value="" />
                            </div>
                        </div>
                        <div class="row g-9 mb-7">
                            <div class="col-md-6 fv-row">
                                <div class="d-flex flex-stack">
                                    <label class="form-check form-switch form-check-custom form-check-solid">
                                        <input id="p_active" class="form-check-input" name="billing" type="checkbox" value="1" checked="checked" />
                                        <span class="form-check-label fw-bold text-muted" for="kt_modal_add_customer_billing">وضعیت</span>
                                    </label>
                                </div>
                            </div>
                            <div class="col-md-6 fv-row">
                                <div class="d-flex flex-stack">
                                    <label class="form-check form-switch form-check-custom form-check-solid">
                                        <span class="form-check-label fw-bold text-muted">خانم</span>
                                        <input id="p_sex" class="form-check-input" name="billing" style="margin: 5px" type="checkbox" value="1" checked="checked" />
                                        <span class="form-check-label fw-bold text-muted">آقا</span>
                                    </label>
                                </div>
                            </div>
                        </div>
                        <div class="row g-9 mb-7">
                            <div class="col-md-6 fv-row">
                                <input id="p_mobile" maxlength="11" class="form-control form-control-solid" placeholder="شماره همراه" value="" />
                            </div>
                            <div class="col-md-6 fv-row">
                                <input id="p_phone" maxlength="15" class="form-control form-control-solid" placeholder="تلفن منزل" value="" />
                            </div>
                        </div>
                        <div class="row g-9 mb-7">
                            <div class="col-md-6 fv-row">
                                <input id="p_username" maxlength="10" class="form-control form-control-solid" placeholder="نام کاربری فقط اعداد و حروف انگلیسی" name="firstname" value="" />
                            </div>
                            <div class="col-md-6 fv-row">
                                <input id="p_pass" maxlength="10" class="form-control form-control-solid" placeholder="رمز عبور" name="lastname" value="" />
                            </div>
                        </div>
                        <div class="row g-9 mb-7" id="div_showCall_A_discount">
                            <div class="col-md-6 fv-row">
                                <div class="d-flex flex-stack">
                                    <label class="form-check form-switch form-check-custom form-check-solid">
                                        <input id="p_showpopup" class="form-check-input" type="checkbox" checked="checked" />
                                        <span class="form-check-label fw-bold text-muted" for="kt_modal_add_customer_billing">نمایش فرم تماس</span>
                                    </label>
                                </div>
                            </div>
                            <div class="col-md-6 fv-row">
                                <input id="p_maxdiscount" maxlength="15" class="form-control form-control-solid" placeholder="حداکثر اعمال تخفیف" value="" />
                            </div>
                        </div>
                        <div class="fv-row mb-15">
                            <input type="text" id="p_desc" class="form-control form-control-solid" placeholder="توضیحات" name="description" />
                        </div>
                        <div class="fv-row mb-15">
                            <input type="text" id="p_address" class="form-control form-control-solid" placeholder="آدرس" />
                        </div>
                    </div>
                </div>
                <div class="modal-footer flex-center">
                    <button id="btn_submitdata" class="btn btn-primary">
                        <span class="indicator-label">ثبت اطلاعات</span>
                    </button>
                    <button type="reset" id="btncancel" class="btn btn-light me-3">انصراف</button>
                </div>
            </div>
        </div>
    </div>

</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="End" runat="server">
    <script type="text/javascript">
        var p_Id = "";
        var regex = new RegExp('^(\\+98|0)?9\\d{9}$');
        var d_showCall_A_discount = document.getElementById('div_showCall_A_discount');
        var p_Pass = document.getElementById('p_pass');
        $("#btn_submitdata").click(function (e) {
            var firstname = $("#p_firstname").val();
            var lastname = $("#p_lastname").val();
            var mobile = $("#p_mobile").val();
            if (mobile != "") {
                var result = regex.test(mobile);
                if (result == false) {
                    toastr.error("شماره همراه را بدرستی وارد کنید", "اخطار");
                    return;
                }
            }
            var phone = $("#p_phone").val();
            var username = $("#p_username").val();
            var pass = $("#p_pass").val();
            var maxdiscount = $("#p_maxdiscount").val();
            var address = $("#p_address").val();
            var active = $("#p_active").prop("checked");
            var sex = $("#p_sex").prop("checked");
            var showpopup = $("#p_showpopup").prop("checked");
            var desc = $("#p_desc").val();
            var roleid = $("#p_role").val();
            $.ajax({
                type: "POST",
                url: "Personnel.aspx/AddEditPersonnel",
                data: "{id:'" + p_Id + "',RoleId:'" + roleid + "',firstname:'" + firstname + "',sex:" + sex + ",active:" + active + ",desc:'" + desc + "',lastname:'" + lastname + "',mobile:'" + mobile + "',phone:'" + phone + "',username:'" + username + "',pass:'" + pass + "',maxdiscount:'" + maxdiscount + "',address:'" + address + "',showpopup:" + showpopup + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    if (msg.d.Result == false) {//خطا داریم
                        ShowError(msg.d.Message);
                    }
                    else {
                        loadTableDataPersonnel();
                        toastr.success(msg.d.Message, "موفق");
                        closeModal();
                    }
                },
                error: function () {
                    alert("error");
                }
            });
        });
        $('#btn_close').click(function () {
            closeModal();
        });
        $('#btncancel').click(function () {
            closeModal();
        });
        function closeModal() {
            $('#kt_modal_add_personnel').modal('hide');
            p_Id = "";
        };
        $("#btn_add").click(function (e) {
            ResetFeilds();
        });
        function ResetFeilds() {
            $("#header_AddPersonnel").text("ثبت پرسنل");
            $("#p_firstname").val("");
            $("#p_lastname").val("");
            $("#p_mobile").val("");
            $("#p_phone").val("");
            $("#p_username").val("");
            $("#p_pass").val("");
            $("#p_maxdiscount").val("");
            $("#p_address").val("");
            p_Id = "";
            $("#p_active").prop("checked", true);
            $("#p_sex").prop("checked", true);
            $("#p_desc").val("");
            d_showCall_A_discount.style.visibility = 'visible';
            p_Pass.style.visibility = 'visible';
        };
        $("#p_role").change(function (e) {
            var roleid = $("#p_role").val();
            $.ajax({
                type: "POST",
                url: "Personnel.aspx/ChangeRole",
                data: "{roleid:'" + roleid + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var result = res.d;
                    if (result.Result == false) {//خطا داریم
                        ShowError(result.Message);
                    }
                    else {
                        if (result.showCall_A_discount == true) {
                            d_showCall_A_discount.style.visibility = 'visible';
                        }
                        else {
                            d_showCall_A_discount.style.visibility = 'hidden';
                        }
                    }
                },
                error: function () {
                    alert("error");
                }
            });
        });
        function DeletePersonnel(id) {
            const userResponse = confirm("آیا از حذف مطمئن هستین؟");
            if (userResponse) {
                $.ajax({
                    type: "POST",
                    url: "Personnel.aspx/DeletePersonnel",
                    data: "{id:'" + id + "'}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (res) {
                        var result = res.d;
                        if (result.Result == false) {//خطا داریم
                            ShowError(result.Message);
                        }
                        else {
                            toastr.success(result.Message, "موفق");
                            loadTableDataPersonnel();
                        }
                    },
                    error: function () {
                        toastr.error("خطا در حذف اطلاعات", "خطا");
                    }
                });
            }
        };
        function EditPerseonnel(id) {
            $.ajax({
                type: "POST",
                url: "Personnel.aspx/EditPersonnel",
                data: "{id:'" + id + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var result = res.d;
                    if (result.Result == false) {//خطا داریم
                        alert(result.Message);
                    }
                    else {
                        p_Id = id;
                        $("#header_AddPersonnel").text("ویرایش " + result.firstname + " " + result.lastname);
                        $("#p_role").val(result.roleId);
                        $("#p_role").select2();
                        $("#p_firstname").val(result.firstname);
                        $("#p_lastname").val(result.lastname);
                        $("#p_mobile").val(result.mobile);
                        $("#p_phone").val(result.phone);
                        $("#p_username").val(result.username);
                        $("#p_pass").val(result.pass);
                        $("#p_maxdiscount").val(result.maxdiscount);
                        $("#p_address").val(result.address);
                        $("#p_active").prop("checked", result.active);
                        $("#p_sex").prop("checked", result.sex);
                        $("#p_desc").val(result.desc);
                        p_Pass.style.visibility = result.ShowPass ? 'visible' : 'hidden';
                    }
                },
                error: function () {
                    toastr.error("خطا در دریافت داده‌ها", "خطا");
                }
            });
        };
        $(document).ready(function () {
            $("#master_PageTitle").text("پرسنل");
            $("#s_pageSize").val("5");
            loadTableDataPersonnel();

            // صفحه بعد
            $("#nextPageBtn").click(function () {
                currentPage++;
                loadTableDataPersonnel();
            });

            // صفحه قبل
            $("#prevPageBtn").click(function () {
                currentPage--;
                loadTableDataPersonnel();
            });

            // اعمال فیلتر
            $("#filterBtn").click(function () {
                currentPage = 1;
                loadTableDataPersonnel();
            });
        });
    </script>
    <script>
        let currentPage = 1;
        let pageSize = 5;

        function loadTableDataPersonnel() {
            var filter = $("#filterInput").val();
            pageSize = parseInt($("#s_pageSize").val());
            $.ajax({
                type: "POST",
                url: "Personnel.aspx/ForGrid",
                data: JSON.stringify({ page: currentPage, perPage: pageSize, searchText: filter }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    const data = response.d.Data.data;
                    const totalRecords = response.d.Data.recordsTotal;
                    const tbody = $("#dt_Personnels");

                    tbody.empty(); // پاک کردن داده‌های قدیمی

                    // اضافه کردن داده‌های جدید
                    data.forEach(row => {
                        tbody.append(`
                        <tr>
                            <td>${row.RoleTitle}</td>
                            <td>${row.FullName}</td>
                            <td>${row.Mobile}</td>
                            <td>${row.Username}</td>
                            <td>${row.Status}</td>
                            <td>${row.Actions}</td>
                        </tr>
                    `);
                    });

                    // بروزرسانی صفحه فعلی
                    $("#currentPage").text(currentPage);
                    $("#countAllTable").text(totalRecords);
                    // غیرفعال کردن دکمه‌های صفحه‌بندی در صورت نیاز
                    $("#prevPageBtn").prop("disabled", currentPage === 1);
                    $("#nextPageBtn").prop("disabled", currentPage * pageSize >= totalRecords);
                },
                error: function () {
                    toastr.error("خطا در دریافت اطلاعات", "خطا");
                }
            });
        }
    </script>
</asp:Content>

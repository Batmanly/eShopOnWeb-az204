﻿using System.Threading.Tasks;
using BlazorAdmin.Interfaces;
using BlazorAdmin.Models;
using BlazorShared.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Logging;

namespace BlazorAdmin.Services;

public class RoleManagementService(HttpService httpService, ILogger<RoleManagementService> logger) : IRoleManagementService
{
    public async Task<RoleListResponse> List(){
        logger.LogInformation("Fetching roles");
        var response = await httpService.HttpGet<RoleListResponse>($"roles");
        return response;
    }

    public async Task<CreateRoleResponse> Create(CreateRoleRequest newRole)
    {
        var response = await httpService.HttpPost<CreateRoleResponse>($"roles", newRole);
        return response;
    }

    public async Task<IdentityRole> Edit(IdentityRole role)
    {
        return await httpService.HttpPut<IdentityRole>($"roles", role);
    }

    public async Task<string> Delete(string id)
    {
        var response = await httpService.HttpDelete<DeleteRoleResponse>($"roles", id);
        return response.Status;
    }

    public async Task<GetByIdRoleResponse> GetById(string id)
    {
        var roleById = await httpService.HttpGet<GetByIdRoleResponse>($"roles/{id}");
        return roleById;
    }
}

# Dockerfile.api (multi-stage) — save as Dockerfile.api in repo root
# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy solution and project csproj for layer caching.
# IMPORTANT: these paths must exist relative to the build context.
COPY ["LearnKing.sln", "./"]
COPY ["LearnKing.Application/*.csproj", "LearnKing.Application/"]
COPY ["LearnKing.Common/*.csproj", "LearnKing.Common/"]
COPY ["LearnKing.Domain/*.csproj", "LearnKing.Domain/"]
COPY ["LearnKing.Infrastructure/*.csproj", "LearnKing.Infrastructure/"]
COPY ["LearnKing.Api/*.csproj", "LearnKing.Api/"]

# restore using the solution
RUN dotnet restore "LearnKing.sln"

# Copy the rest of sources and publish
COPY . .
RUN dotnet publish "LearnKing.Api/LearnKing.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app

# Copy publish output
COPY --from=build /app/publish ./

# Environment settings — make sure port matches EXPOSE / compose mapping
ENV ASPNETCORE_URLS=http://+:86 \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

# Remove debug files to shrink image (optional)
RUN find /app -name "*.pdb" -delete || true && \
    find /app -name "*.xml" -delete || true

EXPOSE 86

ENTRYPOINT ["dotnet", "LearnKing.Api.dll"]

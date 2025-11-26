# FTP Sync Action - Performance Optimization Guide

This guide explains how to optimize the FTP sync action for different server types and connection speeds.

## Quick Start for Slow Servers

If your FTP server is slow or has connection limits, use these settings in your `.env` file:

```bash
# Optimized for slow/shared hosting servers
INPUT_PARALLEL_CONNECTIONS=1      # Single connection only
INPUT_CONNECTION_TIMEOUT=120      # Longer timeout
INPUT_RETRY_COUNT=5               # More retries
INPUT_TRANSFER_RATE_LIMIT=100     # Limit to 100 KB/s
INPUT_DEBUG_MODE=true            # Enable logging
```

## Performance Parameters

| Parameter | Default | Description | Slow Server | Fast Server |
|-----------|---------|-------------|-------------|-------------|
| `INPUT_PARALLEL_CONNECTIONS` | 1 | Number of simultaneous connections | 1 | 3-5 |
| `INPUT_CONNECTION_TIMEOUT` | 60 | Timeout in seconds | 120-300 | 30-60 |
| `INPUT_RETRY_COUNT` | 3 | Number of retry attempts | 5-10 | 2-3 |
| `INPUT_TRANSFER_RATE_LIMIT` | 0 | Speed limit in KB/s (0=unlimited) | 50-200 | 0 |
| `INPUT_DEBUG_MODE` | false | Enable verbose logging | true | false |

## Testing Tools

### 1. Troubleshoot Connection Issues
```bash
./troubleshoot.sh
```
This script will:
- Test basic connectivity
- Verify authentication
- Check directory access
- Measure response times
- Provide specific recommendations

### 2. Find Optimal Settings
```bash
./test-performance.sh
```
This script will:
- Test different parallel connection counts
- Measure sync performance
- Automatically recommend best settings
- Update your `.env` file

### 3. Run with Current Settings
```bash
./run-with-env.sh
```
This script will:
- Load settings from `.env`
- Show current configuration
- Execute the FTP sync

## Common Issues and Solutions

### Issue: Timeouts and Slow Performance
**Symptoms:** Long delays, connection timeouts, partial transfers
**Solution:**
```bash
INPUT_PARALLEL_CONNECTIONS=1
INPUT_CONNECTION_TIMEOUT=180
INPUT_TRANSFER_RATE_LIMIT=100
```

### Issue: Connection Drops
**Symptoms:** "Connection lost" errors, incomplete transfers
**Solution:**
```bash
INPUT_RETRY_COUNT=5
INPUT_PARALLEL_CONNECTIONS=1
INPUT_DEBUG_MODE=true
```

### Issue: Server Overload
**Symptoms:** "Too many connections" errors, server rejection
**Solution:**
```bash
INPUT_PARALLEL_CONNECTIONS=1
INPUT_TRANSFER_RATE_LIMIT=50
```

### Issue: Shared Hosting Limits
**Symptoms:** Authentication failures after working briefly
**Solution:**
```bash
INPUT_PARALLEL_CONNECTIONS=1
INPUT_CONNECTION_TIMEOUT=300
INPUT_RETRY_COUNT=10
INPUT_TRANSFER_RATE_LIMIT=25
```

## Server-Specific Recommendations

### Shared Hosting (cPanel, Plesk)
```bash
INPUT_PARALLEL_CONNECTIONS=1
INPUT_CONNECTION_TIMEOUT=120
INPUT_RETRY_COUNT=5
INPUT_TRANSFER_RATE_LIMIT=100
```

### VPS/Dedicated Servers
```bash
INPUT_PARALLEL_CONNECTIONS=3
INPUT_CONNECTION_TIMEOUT=60
INPUT_RETRY_COUNT=3
INPUT_TRANSFER_RATE_LIMIT=0
```

### Cloud Storage (AWS, GCP, Azure)
```bash
INPUT_PARALLEL_CONNECTIONS=5
INPUT_CONNECTION_TIMEOUT=30
INPUT_RETRY_COUNT=2
INPUT_TRANSFER_RATE_LIMIT=0
```

## Monitoring and Debugging

Enable debug mode to see detailed connection information:
```bash
INPUT_DEBUG_MODE=true
```

This will show:
- Connection attempts and retries
- Transfer speeds and progress
- Server responses and errors
- SSL/TLS negotiation details

## GitHub Actions Usage

In your workflow file:
```yaml
- name: Sync FTP
  uses: ./
  with:
    FTP_USER: ${{ secrets.FTP_USER }}
    FTP_PASSWORD: ${{ secrets.FTP_PASSWORD }}
    FTP_HOST: ${{ secrets.FTP_HOST }}
    FTP_ROOT_FOLDER: './public_html'
    LOCAL_FOLDER: './dist'
    SYNC_MODE: 'upload'
    PARALLEL_CONNECTIONS: '1'      # For slow servers
    CONNECTION_TIMEOUT: '120'      # Longer timeout
    RETRY_COUNT: '5'              # More retries
    TRANSFER_RATE_LIMIT: '100'    # Rate limit for shared hosting
    DEBUG_MODE: 'false'           # Disable in production
```

## Performance Tips

1. **Start Conservative**: Begin with single connections and increase gradually
2. **Test First**: Use the testing tools before production deployment
3. **Monitor Logs**: Enable debug mode during initial setup
4. **Respect Limits**: Many shared hosts have strict connection limits
5. **Use Rate Limiting**: Prevents overwhelming slow servers
6. **Batch Operations**: For many small files, consider archiving first

## Troubleshooting Checklist

- [ ] Run `./troubleshoot.sh` to identify issues
- [ ] Test with `INPUT_PARALLEL_CONNECTIONS=1`
- [ ] Increase timeout to 120+ seconds
- [ ] Enable debug mode for detailed logs
- [ ] Check server documentation for connection limits
- [ ] Verify directory permissions and paths
- [ ] Test during off-peak hours
- [ ] Consider using passive FTP mode

For more help, check the troubleshooting script output or enable debug mode for detailed connection information.